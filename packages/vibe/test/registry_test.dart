import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:vibe/vibe.dart";

void main() {
  late VibeRegistry registry;

  setUp(() {
    registry = VibeRegistry();
  });

  group("VibeRegistry", () {
    test("starts empty", () {
      expect(registry.length, 0);
      expect(registry.all, isEmpty);
      expect(registry.ids, isEmpty);
    });

    test("register and get", () {
      final theme = VibeTheme.fromSeed(
        id: "blue",
        name: "Blue",
        primary: const Color(0xFF0000FF),
      );

      registry.register(theme);

      expect(registry.length, 1);
      expect(registry.get("blue"), same(theme));
      expect(registry.contains("blue"), isTrue);
    });

    test("get returns null for unknown id", () {
      expect(registry.get("unknown"), isNull);
      expect(registry.contains("unknown"), isFalse);
    });

    test("all returns all registered themes", () {
      final a = VibeTheme.fromSeed(
        id: "a",
        name: "A",
        primary: const Color(0xFFFF0000),
      );
      final b = VibeTheme.fromSeed(
        id: "b",
        name: "B",
        primary: const Color(0xFF00FF00),
      );

      registry.register(a);
      registry.register(b);

      expect(registry.all, hasLength(2));
      expect(registry.ids, containsAll(["a", "b"]));
    });

    test("overwrite replaces theme with same id", () {
      final v1 = VibeTheme.fromSeed(
        id: "x",
        name: "X v1",
        primary: const Color(0xFFFF0000),
      );
      final v2 = VibeTheme.fromSeed(
        id: "x",
        name: "X v2",
        primary: const Color(0xFF00FF00),
      );

      registry.register(v1);
      registry.register(v2);

      expect(registry.length, 1);
      expect(registry.get("x")?.name, "X v2");
    });
  });
}
