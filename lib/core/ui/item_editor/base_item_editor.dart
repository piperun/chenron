import 'package:flutter/material.dart';

abstract class BaseItemEditor<T> extends StatefulWidget {
  final Function(T item) onAdd;

  const BaseItemEditor({super.key, required this.onAdd});
}
