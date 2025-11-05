import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/QuestionRequestIdPlant.dart';
import 'package:she_vi/models/choices.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;

class QuestionScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;

  const QuestionScreen({
    super.key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
  });

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late Box box;
  String? username;
  String? visitorid;
  String? email;
  DateTime? lastPressed;

  final ApiService _apiService = ApiService();
  List<QuestionRequestIdPlant> pertanyaan = [];
  List<Map<String, dynamic>> questions = [];

  bool _isLoading = false;
  int currentQuestionIndex = 0;
  int incorrectCount = 0;
  int? selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    _openBox();
    // Mencegah back browser (opsional)
    html.window.history.pushState(null, '', html.window.location.href);
    html.window.onPopState.listen((_) {
      html.window.history.pushState(null, '', html.window.location.href);
    });
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    final token = box.get('token');
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
    });

    if (token == null || token.isEmpty) {
      context.go('/choose-access');
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.fetchQuestionrequestplant(widget.plantId);
      pertanyaan = data;
      questions = data.map((item) {
        final correctChoice = item.question.choices.firstWhere(
          (choice) => item.question.correctAnswers
              .any((ans) => ans.choiceId == choice.id),
          orElse: () =>
              Choice(id: 0, questionId: item.id, choiceText: 'Unknown'),
        );
        return {
          'id': item.id,
          'question_text': item.question.questionText,
          'explanation': item.question.explanation,
          'options': item.question.choices.map((c) => c.choiceText).toList(),
          'answer': correctChoice.choiceText,
        };
      }).toList();
    } catch (e) {
      _showErrorDialog('Gagal memuat soal. Coba lagi nanti.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: Navigator.of(context).pop, child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> nextQuestion(int questionId, int selectedChoiceId) async {
    if (selectedOptionIndex == null) return;

    final correctAnswer = questions[currentQuestionIndex]['answer'] ?? '';
    final options =
        List<String>.from(questions[currentQuestionIndex]['options']);
    final isCorrect = options[selectedOptionIndex!] == correctAnswer;

    try {
      final success = await _apiService.createAnswerQuestion(
        int.parse(widget.idrequest),
        questionId,
        selectedChoiceId,
      );

      if (success) {
        if (!isCorrect) incorrectCount++;

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
                        isCorrect ? 'Correct!' : 'Incorrect',
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
                        'Correct Answer: $correctAnswer',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    questions[currentQuestionIndex]['explanation'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) {
                        if (isCorrect) {
                          // Skor tidak digunakan, jadi dihapus
                        }
                        if (incorrectCount >= 3) {
                          // Akan ditangani di build()
                        } else if (currentQuestionIndex <
                            questions.length - 1) {
                          setState(() {
                            currentQuestionIndex++;
                            selectedOptionIndex = null;
                          });
                        } else {
                          context.go(
                            '/test-complated?idrequest=${widget.idrequest}&plantId=${widget.plantId}&plantName=${widget.plantName}',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: isCorrect
                          ? const Color(0xFF07840B)
                          : const Color(0xFF8F0B0B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      isCorrect ? 'Continue' : 'I Understood',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error submitting answer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF07840B))),
      );
    }

    if (pertanyaan.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada soal tersedia.')),
      );
    }

    final currentQuestion = pertanyaan[currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tekan sekali lagi untuk keluar")),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ CUSTOM HEADER (Menggantikan AppBar)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${currentQuestionIndex + 1} / ${questions.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF343434),
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
                              height: 40,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ✅ KONTEN UTAMA
                        if (incorrectCount < 3) ...[
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentQuestion.question.questionText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF343434),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        currentQuestion.question.choices.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: ElevatedButton(
                                          onPressed: () => setState(() =>
                                              selectedOptionIndex = index),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                selectedOptionIndex == index
                                                    ? Colors.green
                                                    : const Color(0xFFF0F0F0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 16),
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(currentQuestion.question
                                                .choices[index].choiceText),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: selectedOptionIndex != null
                                          ? () {
                                              final choice = currentQuestion
                                                      .question.choices[
                                                  selectedOptionIndex!];
                                              nextQuestion(
                                                  currentQuestion.questionId,
                                                  choice.id);
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            selectedOptionIndex != null
                                                ? const Color(0xFF07840B)
                                                : Colors.grey,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Periksa Jawaban',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        if (incorrectCount >= 3)
                          Center(
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                        'assets/images/groupOfHeart3.png',
                                        height: 40),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'You\'ve lost all your hearts.\nPlease start over.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.go(
                                            '/induction/welcome-test?idrequest=${widget.idrequest}&plantId=${widget.plantId}&plantName=${widget.plantName}',
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF8F0B0B),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Start Over',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
