import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../screens/quiz_screen.dart';

class DetectedObject {
  final String id;
  final String label;
  final String imagePath;
  final int imageWidth;
  final int imageHeight;
  final double confidence;
  final double x;
  final double y;

  DetectedObject({
    required this.id,
    required this.label,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.confidence,
    required this.x,
    required this.y,
  });

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      imagePath: json['imagePath'] ?? '',
      imageWidth: json['imageWidth'] ?? 0,
      imageHeight: json['imageHeight'] ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyzedResultCard extends StatelessWidget {
  final List<DetectedObject> objects;
  final String text;
  final String? prompt;
  final void Function(BuildContext, List<DetectedObject>, String)? onShowTopicPicker;
  const AnalyzedResultCard({
    required this.objects,
    required this.text,
    this.prompt,
    this.onShowTopicPicker,
    super.key,
  });

  String? _extractJson(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.startsWith('```json')) {
      return trimmed.replaceAll(RegExp(r'^```json|```'), '').trim();
    }
    if (trimmed.startsWith('```')) {
      return trimmed.replaceAll(RegExp(r'^```|```'), '').trim();
    }
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      return trimmed;
    }
    return null;
  }

  String? _prettyJson(String? jsonStr) {
    if (jsonStr == null) return null;
    try {
      final decoded = json.decode(jsonStr);
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Remove duplicates by label (case-insensitive)
    final seenLabels = <String>{};
    final uniqueObjects = <DetectedObject>[];
    for (final obj in objects) {
      final label = obj.label.toLowerCase();
      if (!seenLabels.contains(label)) {
        seenLabels.add(label);
        uniqueObjects.add(obj);
      }
    }
    final topics = [
      ...uniqueObjects.map((obj) => obj.label),
      if (text.isNotEmpty) text,
    ].where((t) => t.trim().isNotEmpty).toList();
    final extractedJson = _extractJson(prompt);
    final prettyPrompt = _prettyJson(extractedJson);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final sectionSpacing = isWide ? 28.0 : 18.0;
        final cardPadding = isWide ? 32.0 : 20.0;
        final chipMaxWidth = isWide ? 260.0 : 180.0;
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (uniqueObjects.isNotEmpty) ...[
                  Text(
                    'Detected Objects',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, objConstraints) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: uniqueObjects.map((obj) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: chipMaxWidth),
                            child: Card(
                              elevation: 1,
                              color: theme.colorScheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.label_important_rounded,
                                      color: theme.colorScheme.primary,
                                      size: isWide ? 26 : 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        obj.label,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: isWide ? 18 : 15,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (obj.confidence > 0) ...[
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.bolt,
                                              size: isWide ? 18 : 15,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${(obj.confidence * 100).toStringAsFixed(0)}%',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isWide ? 15 : 13,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: sectionSpacing),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.dividerColor.withOpacity(0.12),
                  ),
                  SizedBox(height: sectionSpacing),
                ],
                if (text.isNotEmpty) ...[
                  Text(
                    'Extracted Text',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SelectableText(
                                text,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'monospace',
                                  fontSize: isWide ? 17 : 14,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            tooltip: 'Copy',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Text copied!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.dividerColor.withOpacity(0.12),
                  ),
                  SizedBox(height: sectionSpacing),
                ],
                if (prompt != null && prompt!.isNotEmpty) ...[
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(Icons.code, color: theme.colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Prompt',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SelectableText(
                                    prettyPrompt ?? extractedJson ?? prompt!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'monospace',
                                      fontSize: isWide ? 16 : 13,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copy',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          prettyPrompt ??
                                          extractedJson ??
                                          prompt!,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Prompt copied!'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.dividerColor.withOpacity(0.12),
                  ),
                  SizedBox(height: sectionSpacing),
                ],
                if ((uniqueObjects.isEmpty) &&
                    (text.isEmpty) &&
                    (prompt == null || prompt!.isEmpty))
                  Text(
                    'No objects, text, or prompt detected.',
                    style: theme.textTheme.bodyMedium,
                  ),
                if ((uniqueObjects.isNotEmpty ||
                    text.isNotEmpty ||
                    (prompt != null && prompt!.isNotEmpty)))
                  Padding(
                    padding: EdgeInsets.only(top: isWide ? 32 : 24),
                    child: Center(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Learn'),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 40 : 32,
                            vertical: isWide ? 20 : 16,
                          ),
                          textStyle: theme.textTheme.titleMedium,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (topics.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No topics detected.'),
                              ),
                            );
                            return;
                          }
                          if (topics.length == 1) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => QuizScreen(topic: topics.first),
                              ),
                            );
                            return;
                          }
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            builder: (ctx) {
                              final theme = Theme.of(ctx);
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  32,
                                  24,
                                  32,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'What do you want to learn about?',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 24),
                                    ...topics.map(
                                      (t) => Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            t,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          onTap: () => Navigator.pop(ctx, t),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          if (selected != null && selected.trim().isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuizScreen(topic: selected.trim()),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
