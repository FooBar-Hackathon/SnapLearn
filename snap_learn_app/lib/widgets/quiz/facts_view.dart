import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

import 'package:snap_learn_app/utils.dart';

class FactsView extends StatefulWidget {
  final List<String> facts;
  final String summary;
  final String difficulty;
  final VoidCallback onContinue;
  final int? countdownSeconds;
  const FactsView({
    required this.summary,
    required this.facts,
    required this.difficulty,
    required this.onContinue,
    this.countdownSeconds,
    super.key,
  });

  @override
  State<FactsView> createState() => _FactsViewState();
}

class _FactsViewState extends State<FactsView> {
  late int _secondsLeft;
  late final Ticker _ticker;
  bool _autoContinued = false;
  bool _showCheckmark = false;
  Timer? _checkmarkTimer;

  @override
  void initState() {
    super.initState();
    _secondsLeft =
        widget.countdownSeconds ??
        utils.getTimerForDifficulty(widget.difficulty);
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_secondsLeft > 0) {
      setState(() {
        _secondsLeft =
            (widget.countdownSeconds ??
                utils.getTimerForDifficulty(widget.difficulty)) -
            elapsed.inSeconds;
      });
      if (_secondsLeft <= 0 && !_autoContinued) {
        _autoContinued = true;
        _showDoneCheckmarkAndContinue();
      }
    }
  }

  void _showDoneCheckmarkAndContinue() {
    setState(() {
      _showCheckmark = true;
    });
    _checkmarkTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) widget.onContinue();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _checkmarkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_showCheckmark) {
      return Center(
        child: Lottie.asset(
          'assets/animations/done-checkmark.json',
          width: 120,
          height: 120,
          repeat: false,
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Chip(
                label: Text(widget.difficulty),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              ),
              const SizedBox(width: 8),
              Text('Learn these facts first', style: theme.textTheme.bodyLarge),
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
                      width: 32,
                      height: 32,
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
        ),
        Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.summarize_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Text(widget.summary, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        Expanded(
          child: widget.facts.isEmpty
              ? Center(
                  child: Text(
                    'No facts available',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.facts.length,
                  itemBuilder: (context, index) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                ' 2${index + 1}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.facts[index]
                                  .replaceAll(RegExp(r'["\\]'), '')
                                  .replaceAll(RegExp(r',\$'), ''),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: widget.onContinue,
            child: const Text('Start Quiz'),
          ),
        ),
      ],
    );
  }
}
