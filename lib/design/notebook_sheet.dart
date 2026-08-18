import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'paper.dart';

class NotebookSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const NotebookSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Paper(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.outline)),
                ),
                child: Row(
                  children: [
                    Text(title!, style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.secondary,
                    )),
                    const Spacer(),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
