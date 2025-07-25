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
  final List<String> facts;
  final List<Map<String, dynamic>> quizzes;
  final String? prompt;
  final void Function(BuildContext, List<DetectedObject>, String)?
  onShowTopicPicker;
  const AnalyzedResultCard({
    required this.objects,
    required this.text,
    this.facts = const [],
    this.quizzes = const [],
    this.prompt,
    this.onShowTopicPicker,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Remove duplicates by label (case-insensitive)
    final seenLabels = <String>{};
    final uniqueObjects = objects.where((obj) {
      final label = obj.label.toLowerCase();
      if (seenLabels.contains(label)) {
        return false;
      } else {
        seenLabels.add(label);
        return true;
      }
    }).toList();

    final topics = [
      ...uniqueObjects.map((obj) => obj.label),
      if (text.isNotEmpty) text,
    ].where((t) => t.trim().isNotEmpty).toList();

    Widget buildSectionHeader(String title, IconData icon) {
      return Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor, width: 1.5),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (uniqueObjects.isNotEmpty) ...[
              buildSectionHeader('Detected Objects', Icons.category_rounded),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: uniqueObjects.map((obj) {
                  return Chip(
                    label: Text(obj.label),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            if (text.isNotEmpty) ...[
              buildSectionHeader('Extracted Text', Icons.text_fields_rounded),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(text, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.copy_all_rounded, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Text copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        tooltip: 'Copy Text',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (facts.isNotEmpty) ...[
              buildSectionHeader('Fun Facts', Icons.lightbulb_rounded),
              const SizedBox(height: 12),
              ...facts.map(
                (fact) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Text(fact, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (quizzes.isNotEmpty) ...[
              buildSectionHeader('Quiz Preview', Icons.quiz_rounded),
              const SizedBox(height: 12),
              _QuizPreview(quizzes: quizzes),
              const SizedBox(height: 24),
            ],
            if (topics.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No topics found to learn about.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              buildSectionHeader('Start Learning', Icons.school_rounded),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final topic = topics[index];
                  return Material(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(topic: topic.trim()),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                topic,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuizPreview extends StatelessWidget {
  final List<Map<String, dynamic>> quizzes;
  const _QuizPreview({required this.quizzes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (quizzes.isEmpty) return const SizedBox.shrink();
    final first = quizzes.first;
    final question = first['question'] as String? ?? '';
    final choices = first['choices'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...choices.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8),
                const SizedBox(width: 8),
                Expanded(child: Text(c.toString())),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
