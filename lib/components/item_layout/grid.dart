import "package:flutter/material.dart";
import "package:chenron/responsible_design/responsive_builder.dart";

//TODO: Might have to move away from GridTileBar since it seems to be very limited
// So might have to write my own custom one

class GridLayout<T> extends StatelessWidget {
  final List<T> items;
  final GridHeader? header;
  final GridFooter? footer;
  final Widget Function(BuildContext, T) itemBuilder;

  const GridLayout({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        int gridColumns = responsiveValue(
          context: context,
          xs: 2,
          sm: 2,
          md: 4,
          lg: 5,
          xl: 6,
        );
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(context, items[index]),
        );
      },
    );
  }
}

class GridItem extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget body;
  final GridHeader? header;
  final GridFooter? footer;

  const GridItem(
      {super.key, this.onTap, required this.body, this.header, this.footer});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap != null ? () => onTap!() : null,
        child: GridTile(
          header: header,
          footer: footer,
          child: body,
        ),
      ),
    );
  }
}

class GridHeader extends StatelessWidget {
  final Widget? leading;
  final Widget? main;
  final Widget? trailing;

  const GridHeader({
    super.key,
    this.main,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 35),
      child: GridTileBar(
        leading: leading,
        title: Expanded(child: main ?? Container()),
        trailing: trailing,
      ),
    );
  }
}

class GridFooter extends StatelessWidget {
  final Widget? main;
  final Widget? trailing;
  const GridFooter({
    super.key,
    this.main,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 35),
      child: GridTileBar(
        title: main,
        trailing: trailing,
      ),
    );
  }
}
