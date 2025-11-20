// lib/screens/external/page/question_screen_external.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;

// MODELS EXTERNAL
import 'package:she_vi/models/question_request_external.dart';
import 'package:she_vi/models/question_external.dart';
import 'package:she_vi/models/choice_external.dart';
import 'package:she_vi/models/correct_answer_external.dart';
import 'package:she_vi/models/plant_external.dart';

// API SERVICE EXTERNAL
import 'package:she_vi/services/api_service_external.dart';

class QuestionScreenExternal extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;
  final String urlakses;

  const QuestionScreenExternal({
    super.key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
    required this.urlakses,
  });

  @override
  _QuestionScreenExternalState createState() => _QuestionScreenExternalState();
}

class _QuestionScreenExternalState extends State<QuestionScreenExternal> {
  DateTime? lastPressed;

  final ApiServiceExternal _api = ApiServiceExternal();

  List<QuestionRequestExternal> pertanyaan = [];
  List<Map<String, dynamic>> questions = [];

  bool _isLoading = false;
  int currentQuestionIndex = 0;
  int incorrectCount = 0;
  int? selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadQuestions());

    // Prevent browser back (web)
    try {
      html.window.history.pushState(null, '', html.window.location.href);
      html.window.onPopState.listen((_) {
        html.window.history.pushState(null, '', html.window.location.href);
      });
    } catch (_) {}
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    try {
      final data = await _api.fetchQuestionrequestplantExternal(widget.plantId);
      pertanyaan = data;

      questions = data.map((item) {
        final correctChoice = item.question.choices.firstWhere(
          (choice) => item.question.correctAnswers
              .any((ans) => ans.choiceId == choice.id),
          orElse: () => ChoiceExternal(
            id: 0,
            questionId: item.question.id,
            choiceText: 'Unknown',
          ),
        );

        return {
          'id': item.id,
          'question_text': item.question.questionText,
          'explanation': item.question.explanation ?? '',
          'options': item.question.choices.map((c) => c.choiceText).toList(),
          'answer': correctChoice.choiceText,
        };
      }).toList();
    } catch (e) {
      _showErrorDialog("Gagal memuat soal. Coba lagi nanti.");
      debugPrint("Error _loadQuestions external: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> nextQuestion(int questionId, int selectedChoiceId) async {
    if (selectedOptionIndex == null) return;

    final correctAnswer = questions[currentQuestionIndex]['answer'] ?? '';
    final options = List<String>.from(questions[currentQuestionIndex]['options'] ?? []);

    final isCorrect = options.isNotEmpty && options[selectedOptionIndex!] == correctAnswer;

    try {
      final success = await _api.createAnswerQuestionExternal(
        int.parse(widget.idrequest),
        questionId,
        selectedChoiceId,
      );

      if (success != null && success.status == true) {
        if (!isCorrect) incorrectCount++;

        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.error,
                        size: 48,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCorrect ? "Correct!" : "Incorrect",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (!isCorrect)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Correct Answer: $correctAnswer",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    questions[currentQuestionIndex]['explanation'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (incorrectCount >= 3) {
                        setState(() {});
                        return;
                      }
                      if (currentQuestionIndex < questions.length - 1) {
                        setState(() {
                          currentQuestionIndex++;
                          selectedOptionIndex = null;
                        });
                      } else {
                        context.go(
                          "/external/test-completed?idrequest=${Uri.encodeComponent(widget.idrequest)}&plantId=${Uri.encodeComponent(widget.plantId)}&plantName=${Uri.encodeComponent(widget.plantName)}&urlakses=${Uri.encodeComponent(widget.urlakses)}",
                        );
                        //context.push('/exsternal/test-completed?id=${item.id}&idrequest=${widget.idrequest}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor:
                          isCorrect ? const Color(0xFF07840B) : const Color(0xFF8F0B0B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isCorrect ? "Continue" : "I Understood",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            );
          },
        );
      } else {
        _showErrorDialog("Gagal mengirim jawaban. Coba lagi.");
      }
    } catch (e) {
      debugPrint("Error submitting answer external: $e");
      _showErrorDialog("Terjadi kesalahan saat mengirim jawaban.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF07840B)),
        ),
      );
    }

    if (pertanyaan.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada soal tersedia.")),
      );
    }

    final current = pertanyaan[currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), // ✅ SAMA DENGAN INTERNAL
            child: Center( // ✅ SAMA DENGAN INTERNAL
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600), // ✅ SAMA DENGAN INTERNAL
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ HEADER: SAMA 100%
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Question ${currentQuestionIndex + 1} / ${questions.length}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF343434), // ✅ SAMA
                          ),
                        ),
                        Image.asset(
                          incorrectCount == 1
                              ? 'assets/images/groupOfHeart1.png'
                              : incorrectCount == 2
                                  ? 'assets/images/groupOfHeart2.png'
                                  : incorrectCount == 3
                                      ? 'assets/images/groupOfHeart3.png'
                                      : 'assets/images/groupOfHeart.png',
                          height: 40, // ✅ SAMA
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // ✅ SAMA

                    // ✅ CARD SOAL: SAMA 100%
                    if (incorrectCount < 3)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(20), // ✅ SAMA
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.question.questionText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF343434), // ✅ SAMA
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: current.question.choices.length,
                                itemBuilder: (context, index) {
                                  final choice = current.question.choices[index];
                                  final selected = selectedOptionIndex == index;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          setState(() => selectedOptionIndex = index),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: selected
                                            ? Colors.green
                                            : const Color(0xFFF0F0F0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 16), // ✅ SAMA
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          choice.choiceText,
                                          style: TextStyle(
                                            color: selected ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: selectedOptionIndex == null
                                      ? null
                                      : () {
                                          final choice = current
                                              .question
                                              .choices[selectedOptionIndex!];

                                          nextQuestion(
                                            current.questionId,
                                            choice.id,
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedOptionIndex != null
                                        ? const Color(0xFF07840B)
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(vertical: 16), // ✅ SAMA
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    "Periksa Jawaban",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ✅ CARD "START OVER": SAMA 100%
                    if (incorrectCount >= 3)
                      Center(
                        child: Card(
                          margin: const EdgeInsets.only(top: 40), // ✅ SAMA
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/groupOfHeart3.png',
                                  height: 40, // ✅ SAMA
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "You've lost all your hearts.\nPlease start over.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18), // ✅ SAMA
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // context.go(
                                      //   '/external/welcome-test-satu'
                                      //   '?idrequest=${Uri.encodeComponent(widget.idrequest)}'
                                      //   '&plantId=${Uri.encodeComponent(widget.plantId)}'
                                      //   '&plantName=${Uri.encodeComponent(widget.plantName)}',
                                      // );
                                      context.push(
                                      '/external/welcome-test-satu',
                                      extra: {
                                        "idrequest": widget.idrequest,
                                        "plantId": widget.plantId,
                                        "plantName": widget.plantName,
                                      },
                                    );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8F0B0B),
                                      padding: const EdgeInsets.symmetric(vertical: 16), // ✅ SAMA
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text(
                                      "Start Over",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}