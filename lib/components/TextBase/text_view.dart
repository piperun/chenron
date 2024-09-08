import 'package:flutter/material.dart';

abstract class TextView extends StatelessWidget {
  const TextView({super.key});

  const factory TextView.header({required String title, bool bold}) =
      HeaderTextView;
  const factory TextView.normal({required String text}) = NormalTextView;
  const factory TextView.listTile({
    required String title,
    required String subtitle,
    IconData? icon,
    bool bold,
  }) = ListTileTextView;
}

class HeaderTextView extends TextView {
  final String title;
  final bool bold;

  const HeaderTextView({super.key, required this.title, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
    );
  }
}

class NormalTextView extends TextView {
  final String text;

  const NormalTextView({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class ListTileTextView extends TextView {
  final String title;
  final String subtitle;
  final IconData? icon;
  final bool bold;

  const ListTileTextView({
    Key? key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.bold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      leading: icon != null ? Icon(icon) : null,
    );
  }
}
