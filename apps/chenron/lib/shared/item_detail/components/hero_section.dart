import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/item_detail/components/link_hero.dart";
import "package:chenron/shared/item_detail/components/folder_hero.dart";
import "package:chenron/shared/item_detail/components/document_hero.dart";

class HeroSection extends StatelessWidget {
  final ItemDetailData data;

  const HeroSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return switch (data.itemType) {
      FolderItemType.link => LinkHero(data: data),
      FolderItemType.document => DocumentHero(data: data),
      FolderItemType.folder => FolderHero(data: data),
    };
  }
}
