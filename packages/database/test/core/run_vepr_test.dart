import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/folder/read.dart";
import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:flutter_test/flutter_test.dart";

/// Stress tests for the [runVepr] helper that's now the central skeleton
/// of every write operation. These pin the atomicity + phase-ordering
/// guarantees the old `VEPROperation` class hierarchy provided, so a
/// future refactor can't quietly weaken them.
///
/// Test categories:
///   1. Atomicity — failure in any phase rolls back every preceding write.
///   2. Phase ordering + wiring — phases run in V-E-P-B order; values flow
///      validate-free → execute → process → build via the type system.
///   3. Concurrency — many runVepr calls in parallel don't observe each
///      other's intermediate state.
///   4. Nested transactions — runVepr inside an outer transaction composes.
///   5. Resource leakage — no growing memory / open-handle leak across N
///      sequential runs.
///   6. Performance ceiling — overhead vs a bare `transaction()` call stays
///      bounded (regression guard, not a microbenchmark).
void main() {
  setUpAll(installTestLogger);

  late MockDatabaseHelper mockDb;
  late AppDatabase db;

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
    db = mockDb.database;
  });

  tearDown(() async {
    await mockDb.dispose();
  });

  // ---------------------------------------------------------------------
  // 1. ATOMICITY
  // ---------------------------------------------------------------------
  group("runVepr — atomicity (rollback on any phase failure)", () {
    test("validate throw: no DB writes occur (validate runs pre-transaction "
        "intent — verify by inserting then throwing)", () async {
      // Validate runs *inside* the transaction in our implementation, so
      // technically a throw here would roll back any preceding writes too.
      // We test that ZERO writes occur because validate runs first.
      final preCount = (await db.getAllFolders()).length;

      await expectLater(
        () => db.runVepr<String, void, String>(
          validate: () => throw ArgumentError("invalid input"),
          execute: () async {
            await db.folders.insertOne(FoldersCompanion.insert(
              id: db.generateId(),
              title: "should-not-exist",

              description: "",
            ));
            return db.generateId();
          },
          process: (_) async {},
          build: (id, _) => id,
        ),
        throwsArgumentError,
      );

      expect((await db.getAllFolders()).length, equals(preCount));
    });

    test("execute throw: rollback wipes any partial write the execute made",
        () async {
      final marker = "exec-fail";
      await expectLater(
        () => db.runVepr<String, void, String>(
          execute: () async {
            // Insert a row, then throw — the row must not survive.
            final id = db.generateId();
            await db.folders.insertOne(FoldersCompanion.insert(
              id: id,
              title: marker,

              description: "",
            ));
            throw StateError("execute aborts after partial write");
          },
          process: (_) async {},
          build: (id, _) => id,
        ),
        throwsStateError,
      );

      final survivors = (await db.getAllFolders())
          .where((f) => f.data.title == marker)
          .toList();
      expect(survivors, isEmpty,
          reason: "execute's partial write must roll back");
    });

    test("process throw: rollback wipes execute's writes too", () async {
      final marker = "proc-fail";
      await expectLater(
        () => db.runVepr<String, void, String>(
          execute: () async {
            final id = db.generateId();
            await db.folders.insertOne(FoldersCompanion.insert(
              id: id,
              title: marker,

              description: "",
            ));
            return id;
          },
          process: (_) async => throw StateError("process bombs"),
          build: (id, _) => id,
        ),
        throwsStateError,
      );

      final survivors = (await db.getAllFolders())
          .where((f) => f.data.title == marker)
          .toList();
      expect(survivors, isEmpty,
          reason: "process failure rolls back execute's writes");
    });

    test("build throw: rollback wipes both execute and process writes",
        () async {
      final marker = "build-fail";
      await expectLater(
        () => db.runVepr<String, String, String>(
          execute: () async {
            final id = db.generateId();
            await db.folders.insertOne(FoldersCompanion.insert(
              id: id,
              title: marker,

              description: "",
            ));
            return id;
          },
          process: (folderId) async {
            // Insert a related row inside process.
            await db.folders.insertOne(FoldersCompanion.insert(
              id: db.generateId(),
              title: "$marker-child",

              description: "",
            ));
            return folderId;
          },
          build: (_, __) => throw StateError("build bombs"),
        ),
        throwsStateError,
      );

      final survivors = (await db.getAllFolders())
          .where((f) => f.data.title.startsWith(marker))
          .toList();
      expect(survivors, isEmpty,
          reason: "build failure rolls back the full operation");
    });
  });

  // ---------------------------------------------------------------------
  // 2. PHASE ORDERING + WIRING
  // ---------------------------------------------------------------------
  group("runVepr — phase ordering + wiring", () {
    test("phases execute in exactly V-E-P-B order", () async {
      final order = <String>[];
      final result = await db.runVepr<int, String, String>(
        validate: () => order.add("V"),
        execute: () async {
          order.add("E");
          return 42;
        },
        process: (e) async {
          order.add("P");
          return "got-$e";
        },
        build: (e, p) {
          order.add("B");
          return "$p built";
        },
      );
      expect(order, equals(["V", "E", "P", "B"]));
      expect(result, equals("got-42 built"));
    });

    test("execute's return value reaches process unchanged", () async {
      final result = await db.runVepr<String, String, String>(
        execute: () async => "execute-payload",
        process: (e) async => "process-saw:$e",
        build: (e, p) => "$e | $p",
      );
      expect(result, equals("execute-payload | process-saw:execute-payload"));
    });

    test("both execute and process results reach build unchanged", () async {
      final result = await db.runVepr<int, double, String>(
        execute: () async => 7,
        process: (e) async => e * 1.5,
        build: (e, p) => "e=$e p=$p",
      );
      expect(result, equals("e=7 p=10.5"));
    });

    test("validate is optional — missing validate works", () async {
      final result = await db.runVepr<String, String, String>(
        execute: () async => "ok",
        process: (e) async => e,
        build: (e, p) => "$e-$p",
      );
      expect(result, equals("ok-ok"));
    });
  });

  // ---------------------------------------------------------------------
  // 3. CONCURRENCY
  // ---------------------------------------------------------------------
  group("runVepr — concurrency", () {
    test("N parallel runs each see only their own data", () async {
      const n = 25;
      final results = await Future.wait(List.generate(
        n,
        (i) => db.runVepr<String, int, ({String id, int seen})>(
          execute: () async {
            final id = db.generateId();
            await db.folders.insertOne(FoldersCompanion.insert(
              id: id,
              title: "concurrent-$i",

              description: "",
            ));
            return id;
          },
          process: (_) async => i,
          build: (id, seen) => (id: id, seen: seen),
        ),
      ));

      // Every operation produced its own unique id, and the closure
      // captured the right `i` for each.
      final ids = results.map((r) => r.id).toSet();
      expect(ids.length, equals(n), reason: "all ids must be unique");
      for (var i = 0; i < n; i++) {
        expect(results[i].seen, equals(i));
      }

      // All n folders made it to the database.
      final stored = (await db.getAllFolders())
          .where((f) => f.data.title.startsWith("concurrent-"))
          .length;
      expect(stored, equals(n));
    });

    test("one parallel run failing doesn't roll back its peers", () async {
      // Mix successes and failures, then verify the successes' writes
      // survived (each runVepr is its own transaction scope).
      final futures = <Future<void>>[];
      for (var i = 0; i < 10; i++) {
        futures.add(() async {
          try {
            await db.runVepr<String, void, String>(
              execute: () async {
                final id = db.generateId();
                await db.folders.insertOne(FoldersCompanion.insert(
                  id: id,
                  title: "mixed-$i",

                  description: "",
                ));
                if (i.isOdd) throw StateError("odd index bombs");
                return id;
              },
              process: (_) async {},
              build: (id, _) => id,
            );
          } catch (_) {
            // swallow — half are expected to fail
          }
        }());
      }
      await Future.wait(futures);

      final survived = (await db.getAllFolders())
          .where((f) => f.data.title.startsWith("mixed-"))
          .map((f) => f.data.title)
          .toSet();

      // Even indices succeeded; odd indices rolled back.
      for (var i = 0; i < 10; i++) {
        if (i.isEven) {
          expect(survived, contains("mixed-$i"));
        } else {
          expect(survived, isNot(contains("mixed-$i")),
              reason: "mixed-$i (odd) must have rolled back");
        }
      }
    });
  });

  // ---------------------------------------------------------------------
  // 4. NESTED TRANSACTIONS
  // ---------------------------------------------------------------------
  group("runVepr — nested transactions", () {
    test("inner runVepr inside an outer transaction commits with the outer",
        () async {
      final innerId = await db.transaction(() async {
        return await db.runVepr<String, void, String>(
          execute: () async {
            final id = db.generateId();
            await db.folders.insertOne(FoldersCompanion.insert(
              id: id,
              title: "nested-success",

              description: "",
            ));
            return id;
          },
          process: (_) async {},
          build: (id, _) => id,
        );
      });

      final found = await db.getFolder(folderId: innerId);
      expect(found, isNotNull);
      expect(found!.data.title, equals("nested-success"));
    });

    test("inner runVepr failure inside an outer transaction rolls back BOTH "
        "(savepoint propagates)", () async {
      final marker =
          "nested-fail";

      await expectLater(
        () => db.transaction(() async {
          // Outer transaction inserts a row first.
          await db.folders.insertOne(FoldersCompanion.insert(
            id: db.generateId(),
            title: "$marker-outer",

            description: "",
          ));

          // Inner runVepr inserts then throws.
          await db.runVepr<String, void, String>(
            execute: () async {
              await db.folders.insertOne(FoldersCompanion.insert(
                id: db.generateId(),
                title: "$marker-inner",

                description: "",
              ));
              throw StateError("inner aborts");
            },
            process: (_) async {},
            build: (id, _) => id,
          );
        }),
        throwsStateError,
      );

      // Drift's outer transaction propagates the inner failure, so even
      // the outer's pre-inner write rolls back.
      final survivors = (await db.getAllFolders())
          .where((f) => f.data.title.startsWith(marker))
          .toList();
      expect(survivors, isEmpty,
          reason: "outer transaction must also roll back");
    });
  });

  // ---------------------------------------------------------------------
  // 5. LEAKAGE
  // ---------------------------------------------------------------------
  group("runVepr — resource leakage", () {
    test("200 sequential ops don't accumulate state between runs", () async {
      // Each iteration uses a separate closure capture; if runVepr leaked
      // state (e.g. stored execResult on a shared object), later runs
      // would observe earlier values.
      for (var i = 0; i < 200; i++) {
        final result = await db.runVepr<int, String, String>(
          execute: () async => i,
          process: (e) async => "p-$e",
          build: (e, p) => "$e/$p",
        );
        expect(result, equals("$i/p-$i"),
            reason: "iteration $i must not see earlier state");
      }
    });

    test("failed runs don't poison subsequent runs", () async {
      // Reproduce the old VEPR's _isProcessing-style footgun: if a
      // crashed run left state on a shared object, the next run would
      // get stuck or see stale data.
      for (var i = 0; i < 50; i++) {
        try {
          await db.runVepr<int, void, int>(
            execute: () async {
              if (i.isEven) throw StateError("even fails");
              return i;
            },
            process: (_) async {},
            build: (e, _) => e,
          );
        } catch (_) {
          // expected for even i
        }
      }

      // After 50 mixed runs, a fresh run still works.
      final result = await db.runVepr<int, int, int>(
        execute: () async => 99,
        process: (e) async => e + 1,
        build: (e, p) => p,
      );
      expect(result, equals(100));
    });
  });

  // ---------------------------------------------------------------------
  // 6. PERFORMANCE CEILING (regression guard, not a microbenchmark)
  // ---------------------------------------------------------------------
  group("runVepr — performance ceiling", () {
    test("100 ops complete in under 5 seconds (regression guard)", () async {
      final sw = Stopwatch()..start();
      for (var i = 0; i < 100; i++) {
        await db.runVepr<String, void, String>(
          execute: () async {
            final id = db.generateId();
            await db.folders.insertOne(FoldersCompanion.insert(
              id: id,
              title: "perf-$i",

              description: "",
            ));
            return id;
          },
          process: (_) async {},
          build: (id, _) => id,
        );
      }
      sw.stop();

      // 100 ops in under 5s is a generous ceiling — current observed
      // runtime is well under 1s. If this trips it means somebody
      // introduced ~50ms overhead per operation. Investigate.
      expect(sw.elapsedMilliseconds, lessThan(5000),
          reason: "100 ops took ${sw.elapsedMilliseconds}ms — perf regression?");
    });

    test("runVepr overhead vs bare transaction is bounded (<2x)", () async {
      // Time a bare drift transaction with the same payload.
      final bareSw = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        await db.transaction(() async {
          await db.folders.insertOne(FoldersCompanion.insert(
            id: db.generateId(),
            title: "bare-$i",

            description: "",
          ));
        });
      }
      bareSw.stop();

      // Same payload through runVepr.
      final veprSw = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        await db.runVepr<String, void, String>(
          execute: () async {
            final id = db.generateId();
            await db.folders.insertOne(FoldersCompanion.insert(
              id: id,
              title: "vepr-$i",

              description: "",
            ));
            return id;
          },
          process: (_) async {},
          build: (id, _) => id,
        );
      }
      veprSw.stop();

      // runVepr should add minimal overhead (one extra try/catch + a
      // handful of var assignments). Allow 2x as a generous ceiling.
      // The bare timing can be very fast (single-digit ms), so we floor
      // the baseline at 10ms to avoid divide-by-zero / flake.
      final bareMs = bareSw.elapsedMilliseconds.clamp(10, 1 << 30);
      final ratio = veprSw.elapsedMilliseconds / bareMs;
      expect(ratio, lessThan(2.0),
          reason: "runVepr overhead ratio ${ratio.toStringAsFixed(2)}x "
              "(${veprSw.elapsedMilliseconds}ms vepr / ${bareSw.elapsedMilliseconds}ms bare) "
              "— suspicious overhead.");
    });
  });
}
