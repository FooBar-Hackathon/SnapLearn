import 'package:flutter/material.dart';

class QuestionCard extends StatefulWidget {
  final Map<String, dynamic> question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;
  final int questionNumber;

  const QuestionCard({
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.questionNumber,
    super.key,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _showHint = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.question['options'] as List? ?? [];
    final points = widget.question['points'] as int? ?? 10;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.questionNumber}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.question['question'] as String? ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$points pts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value as String;
              final optionLetter = String.fromCharCode(65 + index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => widget.onAnswerSelected(optionLetter),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: widget.selectedAnswer == optionLetter
                        ? theme.colorScheme.primary.withAlpha(25)
                        : null,
                    side: BorderSide(
                      color: widget.selectedAnswer == optionLetter
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    '$optionLetter. $option',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              );
            }),
            if (widget.question['explanation'] != null &&
                widget.question['explanation'].toString().isNotEmpty)
              if (_showHint)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: theme.colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.question['explanation'].toString(),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showHint = false;
                              });
                            },
                            child: const Text('Hide Hint'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showHint = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: const Text('Show Hint'),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
