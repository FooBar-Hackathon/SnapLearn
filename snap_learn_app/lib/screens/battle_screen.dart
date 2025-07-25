import 'package:flutter/material.dart';
import 'package:snap_learn_app/Utils.dart';
import '../services/api_service.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  String? _topic;
  String? _difficulty;
  String? _opponent;
  bool _loading = false;
  String? _error;
  List<dynamic> _questions = [];
  Map<int, String> _answers = {};
  bool _submitting = false;
  Map<String, dynamic>? _result;
  String? _battleId;
  int _currentIndex = 0;
  late int _secondsLeft;
  Timer? _timer;
  bool _showCheckmark = false;
  bool _showFireworks = false;
  bool _showXP = false;

  @override
  void initState() {
    super.initState();
    // Optionally: fetch opponents list here for real user selection
  }

  void _startBattle() async {
    setState(() {
      _loading = true;
      _error = null;
      _questions = [];
      _answers = {};
      _result = null;
      _battleId = null;
    });
    try {
      // For demo, just use topic/difficulty; in real app, add opponent selection
      final url = Uri.parse('${ApiService.baseUrl}/Battle/start');
      final response = await ApiService.post(
        url,
        body: {
          'userId': 'YOUR_USER_ID',
          'topic': _topic ?? '',
          'difficulty': _difficulty ?? '',
        },
      );
      _battleId = response['battleId'] ?? '';
      _questions = response['quiz'] ?? [];
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

  Future<void> _submitBattle() async {
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
      final url = Uri.parse('${ApiService.baseUrl}/Battle/submit');
      final response = await ApiService.post(
        url,
        body: {
          'battleId': _battleId ?? '',
          'userId': 'YOUR_USER_ID',
          'answers': answers,
          'difficulty': _difficulty ?? '',
        },
      );
      setState(() {
        _result = response;
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

  void _startQuestionTimer() {
    _timer?.cancel();
    _secondsLeft = utils.getTimerForDifficulty(_difficulty ?? 'medium');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
      });
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    if (_answers[_currentIndex] != null) {
      _goToNextQuestion();
    } else {
      setState(() {
        _answers[_currentIndex] = '';
      });
      _goToNextQuestion();
    }
  }

  void _goToNextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startQuestionTimer();
    } else {
      _showDoneCheckmarkAndSubmit();
    }
  }

  void _showDoneCheckmarkAndSubmit() {
    setState(() {
      _showCheckmark = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _submitBattle();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500;
    if (_showCheckmark) {
      return Scaffold(
        appBar: AppBar(title: const Text('1v1 Battle'), centerTitle: true),
        body: Center(
          child: Lottie.asset(
            'assets/animations/done-checkmark.json',
            width: 120,
            height: 120,
            repeat: false,
          ),
        ),
      );
    }
    if (_showFireworks) {
      return Scaffold(
        appBar: AppBar(title: const Text('1v1 Battle'), centerTitle: true),
        body: Center(
          child: Lottie.asset(
            'assets/animations/fireworks.json',
            width: 220,
            height: 220,
            repeat: false,
            onLoaded: (c) {
              Future.delayed(const Duration(seconds: 2), () {
                setState(() => _showFireworks = false);
              });
            },
          ),
        ),
      );
    }
    if (_showXP) {
      return Scaffold(
        appBar: AppBar(title: const Text('1v1 Battle'), centerTitle: true),
        body: Center(
          child: Lottie.asset(
            'assets/animations/xp_increase.json',
            width: 120,
            height: 120,
            repeat: false,
            onLoaded: (c) {
              Future.delayed(const Duration(seconds: 1), () {
                setState(() => _showXP = false);
              });
            },
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('1v1 Battle'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 48 : 16,
          vertical: 24,
        ),
        child: _loading
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
                      onPressed: _startBattle,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _result != null
            ? _BattleResultView(
                result: _result!,
                onRetry: _startBattle,
                onShowFireworks: () => setState(() => _showFireworks = true),
                onShowXP: () => setState(() => _showXP = true),
              )
            : _questions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start a new battle!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Opponent selection stub
                    DropdownButton<String>(
                      value: _opponent,
                      hint: const Text('Select Opponent'),
                      items: [
                        DropdownMenuItem(
                          value: 'opponent1',
                          child: Text('Opponent 1'),
                        ),
                        DropdownMenuItem(
                          value: 'opponent2',
                          child: Text('Opponent 2'),
                        ),
                      ],
                      onChanged: (val) => setState(() => _opponent = val),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.sports_kabaddi),
                      label: const Text('Start Battle'),
                      onPressed: _startBattle,
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          _difficulty ?? '-',
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Lottie.asset(
                              'assets/animations/countdown.json',
                              width: 28,
                              height: 28,
                              repeat: true,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_secondsLeft s',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
                          : _showDoneCheckmarkAndSubmit,
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

class _BattleResultView extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onRetry;
  final VoidCallback? onShowFireworks;
  final VoidCallback? onShowXP;
  const _BattleResultView({
    required this.result,
    required this.onRetry,
    this.onShowFireworks,
    this.onShowXP,
  });

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
                Icons.sports_kabaddi,
                color: theme.colorScheme.primary,
                size: 54,
              ),
              const SizedBox(height: 18),
              Text(
                'Battle Complete!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Winner: ${result['winner'] ?? '-'}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'XP: ${result['xp'] ?? '-'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Battle Again'),
                onPressed: onRetry,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              if (onShowFireworks != null)
                FilledButton(
                  onPressed: onShowFireworks,
                  child: const Text('Show Fireworks'),
                ),
              if (onShowXP != null)
                FilledButton(onPressed: onShowXP, child: const Text('Show XP')),
            ],
          ),
        ),
      ),
    );
  }
}
