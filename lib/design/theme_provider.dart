import 'package:flutter/material.dart';
import 'nobaro_theme.dart';

class NobaroTheme extends InheritedWidget {
  final NobaroThemeData data;

  const NobaroTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static NobaroThemeData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<NobaroTheme>();
    assert(widget != null, 'No NobaroTheme found in context');
    return widget!.data;
  }

  @override
  bool updateShouldNotify(NobaroTheme oldWidget) => data.name != oldWidget.data.name;
}
