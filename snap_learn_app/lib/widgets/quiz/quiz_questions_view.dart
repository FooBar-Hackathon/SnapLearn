import 'package:flutter/material.dart';
import 'package:snap_learn_app/Utils.dart';
import 'question_card.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class QuizQuestionsView extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Map<int, String> answers;
  final String difficulty;
  final bool submitting;
  final Function(int, String) onAnswerSelected;
  final VoidCallback onSubmit;

  const QuizQuestionsView({
    required this.questions,
    required this.answers,
    required this.difficulty,
    required this.submitting,
    required this.onAnswerSelected,
    required this.onSubmit,
    super.key,
  });

  @override
  State<QuizQuestionsView> createState() => _QuizQuestionsViewState();
}

class _QuizQuestionsViewState extends State<QuizQuestionsView> {
  final PageController _pageController = PageController();
  late int _secondsLeft;
  Timer? _timer;
  int _currentIndex = 0;
  bool _showCheckmark = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = utils.getTimerForDifficulty(widget.difficulty);
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
    // If already answered, just go to next question
    if (widget.answers[_currentIndex] != null) {
      _goToNextQuestion();
    } else {
      widget.onAnswerSelected(_currentIndex, ''); // Mark as unanswered
      _goToNextQuestion();
    }
  }

  void _goToNextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _startTimer();
    } else {
      _showDoneCheckmarkAndSubmit();
    }
  }

  void _showDoneCheckmarkAndSubmit() {
    setState(() {
      _showCheckmark = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) widget.onSubmit();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allAnswered = widget.answers.length == widget.questions.length;
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
              Text(
                'Answered ${widget.answers.length}/${widget.questions.length}',
                style: theme.textTheme.bodyLarge,
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
              if (allAnswered)
                FilledButton(
                  onPressed: widget.submitting
                      ? null
                      : _showDoneCheckmarkAndSubmit,
                  child: widget.submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Submit'),
                ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.questions.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _startTimer();
            },
            itemBuilder: (context, index) {
              final question = widget.questions[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: QuestionCard(
                  question: question,
                  selectedAnswer: widget.answers[index],
                  onAnswerSelected: (answer) {
                    widget.onAnswerSelected(index, answer);
                    // Optionally, auto-advance on answer
                  },
                  questionNumber: index + 1,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
                label: const Text('Next'),
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
