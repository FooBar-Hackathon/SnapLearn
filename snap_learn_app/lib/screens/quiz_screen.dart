import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final String topic;
  final String? initialDifficulty;
  final String? userId;
  const QuizScreen({
    required this.topic,
    this.initialDifficulty,
    this.userId,
    super.key,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? _difficulty;
  bool _loading = false;
  String? _error;
  List<dynamic> _questions = [];
  Map<int, String> _answers = {};
  bool _submitting = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty;
    if (_difficulty != null) {
      _fetchQuiz();
    }
  }

  Future<void> _fetchQuiz() async {
    setState(() {
      _loading = true;
      _error = null;
      _questions = [];
      _answers = {};
      _result = null;
    });
    try {
      final data = await ApiService.generateQuiz(widget.topic, _difficulty!);
      setState(() {
        _questions = data['questions'] ?? [];
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _submitQuiz() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final answers = List<Map<String, String>>.generate(_questions.length, (
        i,
      ) {
        final q = _questions[i];
        return {
          'question':
              (q is Map && q['question'] != null ? q['question'] : q.toString())
                  .toString(),
          'selected': (_answers[i] ?? '').toString(),
        };
      });
      final data = await ApiService.submitQuiz(
        widget.userId ?? '',
        answers,
        _difficulty!,
      );
      setState(() {
        _result = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  void _pickDifficulty() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Difficulty',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ...['Easy', 'Medium', 'Hard', 'Expert'].map(
                (d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, d),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                    child: Text(d),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _difficulty = picked);
      _fetchQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500;
    return Scaffold(
      appBar: AppBar(title: Text('Quiz: ${widget.topic}'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 48 : 16,
          vertical: 24,
        ),
        child: _difficulty == null
            ? Center(
                child: FilledButton(
                  onPressed: _pickDifficulty,
                  child: const Text('Pick Difficulty'),
                ),
              )
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _fetchQuiz,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _result != null
            ? _QuizResultView(result: _result!, onRetry: _fetchQuiz)
            : _questions.isEmpty
            ? Center(
                child: Text(
                  'No questions found.',
                  style: theme.textTheme.bodyLarge,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          _difficulty!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Questions: ${_questions.length}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (ctx, i) {
                        final q = _questions[i];
                        final question = q is Map && q['question'] != null
                            ? q['question']
                            : q.toString();
                        final options = q is Map && q['options'] is List
                            ? List<String>.from(q['options'])
                            : <String>[];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q${i + 1}. $question',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ...options.map(
                                  (opt) => RadioListTile<String>(
                                    value: opt,
                                    groupValue: _answers[i],
                                    onChanged: (val) {
                                      setState(() => _answers[i] = val!);
                                    },
                                    title: Text(
                                      opt,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: Text(_submitting ? 'Submitting...' : 'Submit'),
                      onPressed:
                          _submitting || _answers.length != _questions.length
                          ? null
                          : _submitQuiz,
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
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onRetry;
  const _QuizResultView({required this.result, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                color: theme.colorScheme.primary,
                size: 54,
              ),
              const SizedBox(height: 18),
              Text(
                'Quiz Complete!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Correct: ${result['correct'] ?? '-'} / ${result['total'] ?? '-'}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'XP: ${result['xp'] ?? '-'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              if ((result['bonus'] ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${result['bonus']} Bonus XP!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                onPressed: onRetry,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
