import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../design/paper.dart';
import '../../core/models/template.dart';
import '../../data/session_state.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final SessionState _session = SessionState();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    final templates = _session.templates;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surfaceContainer,
        title: Text('TEMPLATES', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.secondary, fontSize: 14)),
        iconTheme: IconThemeData(color: theme.secondary),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.outline),
        ),
      ),
      body: Row(
        children: [
          // Left: List
          Container(
            width: 180,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: theme.outline)),
            ),
            child: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final selected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    color: selected ? theme.primary.withValues(alpha: 0.2) : Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          templates[index].name,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? theme.primary : theme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uses: ${templates[index].useCount}',
                          style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: theme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Right: Preview
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DESCRIPTION', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    templates[_selectedIndex].description,
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: theme.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Text('TAGS', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
                  Text(
                    templates[_selectedIndex].tags,
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.secondary),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('PREVIEW', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.surfaceContainerLowest,
                        border: Border.all(color: theme.outline.withValues(alpha: 0.3)),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _session.templateRepo.expandContent(templates[_selectedIndex]),
                          style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface, height: 1.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 48,
        decoration: BoxDecoration(
          color: theme.surfaceContainer,
          border: Border(top: BorderSide(color: theme.outline)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CLOSE', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.tertiary)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final t = templates[_selectedIndex];
                final content = _session.templateRepo.expandContent(t);
                t.useCount++;
                _session.templateRepo.save(templates);
                Navigator.of(context).pop({'content': content, 'tags': t.tags});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('APPLY TEMPLATE', style: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
