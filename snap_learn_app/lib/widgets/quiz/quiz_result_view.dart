import 'package:flutter/material.dart';
import 'result_stat.dart';

class QuizResultView extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onRetry;
  final String topic;
  const QuizResultView({
    required this.result,
    required this.onRetry,
    required this.topic,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = result['correct'] as int? ?? 0;
    final total = result['total'] as int? ?? 0;
    final xp = result['xp'] as int? ?? 0;
    final bonus = result['bonus'] as int? ?? 0;
    final percentageRaw = result['percentage'];
    final percentage = percentageRaw is int
        ? percentageRaw.toDouble()
        : (percentageRaw as double? ?? 0.0);
    final grade = result['grade'] as String? ?? '';
    final breakdown = result['breakdown'] as List? ?? [];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(Icons.emoji_events, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz Complete!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(topic, style: theme.textTheme.titleMedium),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ResultStat(
                          value: '$correct/$total',
                          label: 'Correct',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        ResultStat(
                          value: '${percentage.toStringAsFixed(1)}%',
                          label: 'Score',
                          icon: Icons.bar_chart,
                          color: theme.colorScheme.primary,
                        ),
                        if (grade.isNotEmpty)
                          ResultStat(
                            value: grade,
                            label: 'Grade',
                            icon: Icons.grade,
                            color: Colors.amber,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'XP: $xp',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (bonus > 0) ...[
                          const SizedBox(width: 16),
                          Text(
                            '+$bonus Bonus',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (breakdown.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Question Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...breakdown.map((item) {
                  final isCorrect = item['selected'] == item['correct'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check : Icons.close,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['question'] ?? '',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your answer: ${item['selected'] ?? ''}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (!isCorrect)
                              Text(
                                'Correct answer: ${item['correct'] ?? ''}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Topics'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
