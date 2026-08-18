import 'package:flutter/material.dart';
import 'theme_provider.dart';

class Paper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? width;
  final double? height;
  final bool showBorder;
  final bool showShadow;
  final EdgeInsetsGeometry? margin;

  const Paper({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.width,
    this.height,
    this.showBorder = true,
    this.showShadow = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? theme.surfaceContainer,
        border: showBorder ? Border.all(color: theme.outline) : null,
        boxShadow: showShadow
            ? [BoxShadow(
                color: theme.outline.withValues(alpha: 0.3),
                offset: const Offset(4, 4),
                blurRadius: 0,
              )]
            : null,
      ),
      child: child,
    );
  }
}
