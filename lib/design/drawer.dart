import 'package:flutter/material.dart';
import 'theme_provider.dart';

class NobaroDrawer extends StatelessWidget {
  final Widget child;
  final double? height;

  const NobaroDrawer({
    super.key,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    return Container(
      width: double.infinity,
      height: height ?? 300,
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        border: Border(top: BorderSide(color: theme.outline)),
      ),
      child: child,
    );
  }
}
