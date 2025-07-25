import 'package:flutter/material.dart';
import 'question_card.dart';

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allAnswered = widget.answers.length == widget.questions.length;

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
                'Question Answered ${widget.answers.length}/${widget.questions.length}',
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              if (allAnswered)
                FilledButton(
                  onPressed: widget.submitting ? null : widget.onSubmit,
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
            itemBuilder: (context, index) {
              final question = widget.questions[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: QuestionCard(
                  question: question,
                  selectedAnswer: widget.answers[index],
                  onAnswerSelected: (answer) {
                    widget.onAnswerSelected(index, answer);
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
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
              ),
              IconButton(
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
