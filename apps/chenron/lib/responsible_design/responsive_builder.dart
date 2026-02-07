import "package:flutter/material.dart";
import "package:chenron/responsible_design/breakpoints.dart";

class ResponsiveValue<T> {
  final T xs;
  final T sm;
  final T md;
  final T lg;
  final T xl;

  ResponsiveValue({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  T value(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.xl) {
      return xl;
    } else if (width >= Breakpoints.lg) {
      return lg;
    } else if (width >= Breakpoints.md) {
      return md;
    } else if (width >= Breakpoints.sm) {
      return sm;
    } else {
      return xs;
    }
  }
}

T responsiveValue<T>({
  required BuildContext context,
  required T xs,
  required T sm,
  required T md,
  required T lg,
  required T xl,
}) {
  return ResponsiveValue(
    xs: xs,
    sm: sm,
    md: md,
    lg: lg,
    xl: xl,
  ).value(context);
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
      builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: builder,
    );
  }
}

