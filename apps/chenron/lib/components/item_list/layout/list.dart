import "package:flutter/material.dart";

class ListLayout<T> extends StatelessWidget {
  final List<T> items;
  final bool Function(T) isItemSelected;
  final Function(T)? onItemToggle;
  final Function(T)? onTap;
  final Widget Function(BuildContext, T) itemWidgetBuilder;

  const ListLayout({
    super.key,
    required this.items,
    required this.isItemSelected,
    required this.onItemToggle,
    required this.onTap,
    required this.itemWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) => itemWidgetBuilder(context, items[index]),
    );
  }
}

class ListItem extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  const ListItem({
    super.key,
    this.onTap,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: ListTile(
          onTap: onTap,
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        ),
      ),
    );
  }
}

class ListItemLeading extends StatelessWidget {
  final Widget child;

  const ListItemLeading({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ListItemTitle extends StatelessWidget {
  final Widget child;

  const ListItemTitle({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ListItemSubtitle extends StatelessWidget {
  final Widget child;

  const ListItemSubtitle({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ListItemTrailing extends StatelessWidget {
  final Widget child;

  const ListItemTrailing({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/*
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = isItemSelected(item);
        return ListItem(
          onTap: () => onTap!(item),
        );
      },
          title: itemBuilder(item),
          titleAlignment: ListTileTitleAlignment.center,
          trailing: Checkbox(
            value: isSelected,
            onChanged: (bool? value) => onItemToggle!(item),
          ),
          */