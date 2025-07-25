import 'package:flutter/material.dart';
import 'package:snap_learn_app/widgets/quiz/difficulty_option.dart';
import 'package:snap_learn_app/widgets/quiz/difficulty_selection_view.dart';
import 'package:snap_learn_app/widgets/quiz/error_view.dart';
import 'package:snap_learn_app/widgets/quiz/facts_view.dart';
import 'package:snap_learn_app/widgets/quiz/quiz_questions_view.dart';
import 'package:snap_learn_app/widgets/quiz/quiz_result_view.dart';
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
  String _summary = '';
  List<Map<String, dynamic>> _questions = [];
  Map<int, String> _answers = {};
  bool _submitting = false;
  Map<String, dynamic>? _result;
  List<String> _facts = [];
  bool _showingFacts = false;
  String? _quizId; // Store the quizId

  @override
  void initState() {
    super.initState();
    _difficulty = null;
  }

  Future<void> _fetchFacts() async {
    setState(() {
      _loading = true;
      _error = null;
      _facts = [];
      _questions = [];
      _answers = {};
      _result = null;
      _summary = '';
      _showingFacts = true;
    });
    try {
      final data = await ApiService.getFacts(widget.topic, _difficulty!);
      final summary = data['summary'] as String? ?? '';
      final factsList = data['facts'] as List?;

      if (factsList == null) {
        throw Exception('No facts found in response.');
      }

      final facts = factsList.cast<String>().toList();

      setState(() {
        _summary = summary;
        _facts = facts;
        _showingFacts = true;
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

  Future<void> _fetchQuiz() async {
    setState(() {
      _loading = true;
      _error = null;
      _questions = [];
      _answers = {};
      _result = null;
      _showingFacts = false;
    });
    try {
      final data = await ApiService.generateQuiz(widget.topic, _difficulty!);
      final questionsList = data['questions'] as List?;
      if (questionsList != null) {
        setState(() {
          _questions = questionsList.cast<Map<String, dynamic>>();
          _quizId = data['quizId']?.toString(); // Store quizId
        });
      } else {
        throw Exception('No questions found in response.');
      }
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
        final question = _questions[i];
        final questionText = question['question'] as String? ?? '';
        final selected = _answers[i] ?? '';
        return {'question': questionText, 'selected': selected};
      });
      if (_quizId == null) throw Exception('Quiz ID missing.');
      final data = await ApiService.submitQuiz(answers, _difficulty!, _quizId!);
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
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DifficultyOption(
              difficulty: 'Easy',
              selected: _difficulty == 'Easy',
              color: Colors.green,
              onTap: () => Navigator.pop(context, 'Easy'),
            ),
            DifficultyOption(
              difficulty: 'Medium',
              selected: _difficulty == 'Medium',
              color: Colors.blue,
              onTap: () => Navigator.pop(context, 'Medium'),
            ),
            DifficultyOption(
              difficulty: 'Hard',
              selected: _difficulty == 'Hard',
              color: Colors.orange,
              onTap: () => Navigator.pop(context, 'Hard'),
            ),
            DifficultyOption(
              difficulty: 'Expert',
              selected: _difficulty == 'Expert',
              color: Colors.red,
              onTap: () => Navigator.pop(context, 'Expert'),
            ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => _difficulty = picked);
      _fetchFacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showingFacts ? _fetchFacts : _fetchQuiz,
          ),
        ],
      ),
      body: _difficulty == null
          ? DifficultySelectionView(
              onDifficultySelected: (picked) {
                setState(() => _difficulty = picked);
                _fetchFacts();
              },
            )
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ErrorView(
              error: _error!,
              onRetry: _showingFacts ? _fetchFacts : _fetchQuiz,
            )
          : _result != null
          ? QuizResultView(
              result: _result!,
              onRetry: _fetchQuiz,
              topic: widget.topic,
            )
          : _showingFacts
          ? FactsView(
              summary: _summary,
              facts: _facts,
              difficulty: _difficulty!,
              onContinue: _fetchQuiz,
            )
          : _questions.isEmpty
          ? const Center(child: Text('No questions found.'))
          : QuizQuestionsView(
              questions: _questions,
              answers: _answers,
              difficulty: _difficulty!,
              onSubmit: _submitQuiz,
              submitting: _submitting,
              onAnswerSelected: (index, answer) {
                setState(() {
                  _answers[index] = answer;
                });
              },
            ),
    );
  }
}
