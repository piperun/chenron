import 'package:chenron/database/database.dart';
import "package:drift/drift.dart";
import 'package:rxdart/rxdart.dart';

enum IncludeLinkData { all, tags, none }

class LinkResult {
  final Link link;
  List<Tag> tags = [];

  LinkResult({required this.link});
}

extension LinkReadExtensions on AppDatabase {
  Future<LinkResult?> getLink(String linkId,
      {IncludeLinkData mode = IncludeLinkData.none}) async {
    return LinkQueryBuilder(db: this, linkId: linkId, mode: mode).fetchSingle();
  }

  Future<List<LinkResult>> getAllLinks(
      {IncludeLinkData mode = IncludeLinkData.none}) {
    return LinkQueryBuilder(db: this, mode: mode).fetchAll();
  }

  Stream<LinkResult> watchLink(
      {linkId, IncludeLinkData mode = IncludeLinkData.none}) {
    return LinkQueryBuilder(linkId: linkId, db: this, mode: mode).watchSingle();
  }

  Stream<List<LinkResult>> watchAllLinks(
      {IncludeLinkData mode = IncludeLinkData.none}) {
    return LinkQueryBuilder(db: this, mode: mode).watchAll();
  }
}

class LinkQueryBuilder {
  final AppDatabase db;
  final IncludeLinkData mode;
  final String? linkId;

  LinkQueryBuilder({required this.db, this.linkId, required this.mode});

  Future<List<LinkResult>> fetchAll() async {
    final links = await _getAllLinks();
    final results = <LinkResult>[];

    for (final link in links) {
      final result = LinkResult(link: link);
      if (mode == IncludeLinkData.all || mode == IncludeLinkData.tags) {
        result.tags = await _getTags(link.id);
      }
      results.add(result);
    }

    return results;
  }

  Future<LinkResult> fetchSingle() async {
    if (linkId == null) {
      throw Exception("Link id is null");
    }
    final link = await _getLink(linkId!);
    final result = LinkResult(link: link);
    if (mode == IncludeLinkData.none) {
      return result;
    }

    if (mode == IncludeLinkData.all || mode == IncludeLinkData.tags) {
      result.tags = await _getTags(link.id);
    }

    return result;
  }

  Stream<LinkResult> watchSingle() {
    if (linkId == null) {
      throw ArgumentError("linkId must be provided for watching a single link");
    }

    final linkStream =
        (db.select(db.links)..where((l) => l.id.equals(linkId!))).watchSingle();

    if (mode == IncludeLinkData.none) {
      return linkStream.map((link) => LinkResult(link: link));
    }

    final tagsStream =
        mode == IncludeLinkData.all || mode == IncludeLinkData.tags
            ? _watchTags(linkId!)
            : Stream.value(<Tag>[]);

    return Rx.combineLatest2(
      linkStream,
      tagsStream,
      (Link link, List<Tag> tags) {
        final result = LinkResult(link: link);
        result.tags = tags;
        return result;
      },
    );
  }

  Stream<List<LinkResult>> watchAll() {
    final linksStream = db.select(db.links).watch();

    return linksStream.switchMap((links) {
      final linkStreams = links.map((link) {
        final tagsStream =
            mode == IncludeLinkData.all || mode == IncludeLinkData.tags
                ? _watchTags(link.id)
                : Stream.value(<Tag>[]);

        return Rx.combineLatest2(
          Stream.value(link),
          tagsStream,
          (Link l, List<Tag> tags) {
            final result = LinkResult(link: l);
            result.tags = tags;
            return result;
          },
        );
      });

      return Rx.combineLatestList(linkStreams);
    });
  }

  Future<Link> _getLink(String linkId) {
    return (db.select(db.links)..where((l) => l.id.equals(linkId))).getSingle();
  }

  Future<List<Link>> _getAllLinks() {
    return db.select(db.links).get();
  }

  Future<List<Tag>> _getTags(String linkId) {
    final rows = (db.select(db.metadataRecords).join([
      leftOuterJoin(
          db.tags, db.tags.id.equalsExp(db.metadataRecords.metadataId)),
    ])
          ..where(db.metadataRecords.itemId.equals(linkId)))
        .map((row) {
      final tag = row.readTable(db.tags);
      return tag;
    }).get();

    return rows.then((tags) => tags.whereType<Tag>().toList());
  }

  Stream<List<Tag>> _watchTags(String linkId) {
    return (db.select(db.metadataRecords).join([
      leftOuterJoin(
          db.tags, db.tags.id.equalsExp(db.metadataRecords.metadataId)),
    ])
          ..where(db.metadataRecords.itemId.equals(linkId)))
        .watch()
        .map((rows) => rows.map((row) => row.readTable(db.tags)).toList());
  }
}
