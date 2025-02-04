import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/QuestionRequestIdPlant.dart';
import 'package:she_vi/models/choices.dart';
import 'package:go_router/go_router.dart';

class QuestionScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;

  const QuestionScreen({
    Key? key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
  }) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  //GlobalKey<ScaffoldState> _formKey_Q = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


  late Box box;
  String? username;
  String? visitorid;
  String? email;
  ApiService apiService = ApiService();
  List<QuestionRequestIdPlant> questionlist = [];

  bool _isLoading = false;
  int currentQuestionIndex = 0;
  int incorrectCount = 0;
  int score = 0;
  int? selectedOptionIndex;
  late QuestionRequestIdPlant currentQuestion;

  late Future<List<QuestionRequestIdPlant>>? futureQuestionrequest;
  List<QuestionRequestIdPlant> pertanyaan = [];
  List<Map<String, dynamic>> questions = [];

  int questionIndex = 0;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox'); // Buka box 'userBox'
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token'); // Ambil token
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context,
            '/chooseaccess'); // Ganti '/login' dengan nama route halaman login
      } else {
        setState(() {});
        _loadData();
      }
    });
  }

  void _loadData() async {
    setState(() => _isLoading = true); // Mulai loading indikator

    try {
      final String plantId = widget.plantId;
      print('Fetching data for Plant ID: $plantId');

      // Panggil API untuk mendapatkan data pertanyaan
      pertanyaan = await apiService.fetchQuestionrequestplant(plantId);
      print('Data pertanyaan diterima: $pertanyaan');

      // Proses data yang diterima
      questions = pertanyaan.map((item) {
        print('Processing question with ID: ${item.id}');
        print('Choices: ${item.question.choices}');
        print('Correct Answers: ${item.question.correctAnswers}');

        // Log setiap pilihan
        for (var choice in item.question.choices) {
          print('Choice ID: ${choice.id}, Text: ${choice.choiceText}');
        }

        // Log setiap jawaban benar
        for (var correctAnswer in item.question.correctAnswers) {
          print('Correct Answer ID: ${correctAnswer.choiceId}');
        }

        // Cari pilihan yang cocok dengan jawaban benar
        final correctChoice = item.question.choices.firstWhere(
              (choice) =>
              item.question.correctAnswers.any((ans) => ans.choiceId == choice.id),
          orElse: () => Choice(
            id: 0,
            questionId: item.id,
            choiceText: 'Unknown',
          ),
        );

        print('Selected Correct Choice: ${correctChoice.choiceText}');

        // Kembalikan data dalam bentuk map untuk UI
        return {
          'id': item.id,
          'question_text': item.question.questionText,
          'explanation': item.question.explanation,
          'options': item.question.choices.map((choice) => choice.choiceText).toList(),
          'answer': correctChoice.choiceText,
        };
      }).toList();

      print('Data berhasil diproses: $questions');

      // Debugging akhir untuk memverifikasi data
      for (var question in questions) {
        print('Question ID: ${question['id']}');
        print('Question Text: ${question['question_text']}');
        print('Options: ${question['options']}');
        print('Correct Answer: ${question['answer']}');
        print('Explanation: ${question['explanation']}');
      }
    } catch (error) {
      print('Error loading data: $error');

      // Menampilkan dialog kesalahan
      _showErrorDialog(
        'Gagal memuat data. Pastikan koneksi internet stabil atau coba lagi nanti.',
      );
    } finally {
      // Pastikan loading indikator dihentikan meskipun terjadi kesalahan
      setState(() => _isLoading = false);
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> nextQuestion(int questionId, int selectedChoiceId) async {
    if (selectedOptionIndex != null) {
      final String correctAnswer = questions[currentQuestionIndex]['answer'] ?? '';
      List<String> options = List<String>.from(questions[currentQuestionIndex]['options']);
      bool isCorrect = options[selectedOptionIndex!] == correctAnswer;

      // Kirim data ke API setelah memilih opsi
      final int idrequest = int.parse(widget.idrequest.toString());
      //final int question_id = int.parse(questions[currentQuestionIndex]['id'].toString());
      final int question_id = questionId;
      final int choice_id = selectedChoiceId;

      try {
        final result = await apiService.createAnswerQuestion(
          idrequest,
          question_id,
          choice_id,
        );
        // Cek jika berhasil
        if (result) {
          if (!isCorrect) {
            incorrectCount++; // Tambah jumlah kesalahan
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  top: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.error,
                          size: 48.0,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          isCorrect ? 'Correct!' : 'Incorrect',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (!isCorrect)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Correct Answer: $correctAnswer',
                          style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                        ),
                      ),
                    SizedBox(height: 8.0),
                    Text(
                      questions[currentQuestionIndex]['explanation'] ?? '',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        if (mounted) {
                          setState(() {
                            if (isCorrect) {
                              score++;
                            }

                            if (incorrectCount >= 3) {
                              //_showResult();
                              // Navigasi langsung setelah dialog ditutup
                              // Navigator.pushReplacementNamed(
                              //   context,
                              //   '/request-induction',
                              //   arguments: {'username': username ?? 'defaultID'},
                              // );
                              return;
                            }

                            if (currentQuestionIndex < questions.length - 1) {
                              currentQuestionIndex++;
                            } else {

                              context.go(
                                '/test-complated?idrequest=${widget.idrequest ?? ''}&plantId=${widget.plantId?.toString() ?? ''}&plantName=${widget.plantName ?? ''}',
                              );
                            }

                            selectedOptionIndex = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: isCorrect ? Color(0xFF07840B) : Color(0xFF8F0B0B),
                      ),
                      child: Text(
                        isCorrect ? 'Continue' : 'I Understood',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

        } else {
          print('Insert Data Gagal');
        }
      } catch (e) {
        print('Terjadi kesalahan');
      }

    } else {
      print('No option selected!');
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  'assets/images/groupOfHeart3.png',
                  height: 40.0,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 40.0),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'You\'ve lost all your hearts. Please start over.',
                style: TextStyle(
                  color: Color(0xFF343434),
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 20.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Tutup dialog terlebih dahulu
                  Navigator.of(context).pop();

                  // Navigasi langsung setelah dialog ditutup

                  Future.delayed(Duration(milliseconds: 500), () {
                    if (mounted) {  // Pastikan widget masih mounted
                      Navigator.pushReplacementNamed(
                        context,
                        '/request-induction',
                        arguments: {'username': username ?? 'defaultID'},
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0x8F0B0B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text(
                  'Start Over',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    // Jika data kosong, tampilkan pesan
    if (pertanyaan.isEmpty) {
      return const Center(
        child: Text('Tidak ada data tersedia.'),
      );
    }
    // Ambil pertanyaan saat ini
    final currentQuestion = pertanyaan[currentQuestionIndex];
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        //key: _formKey_Q,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Question ${currentQuestionIndex + 1} / ${questions.length}',
            style: TextStyle(
              color: Color(0xFF343434),
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              height: 1.0,
            ),
          ),
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 2,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                // Memilih gambar berdasarkan jumlah kesalahan
                incorrectCount == 1
                    ? 'assets/images/groupOfHeart1.png'  // Jika salah 1, gambar groupOfHeart1.png
                    : incorrectCount == 2
                    ? 'assets/images/groupOfHeart2.png'  // Jika salah 2, gambar groupOfHeart3.png
                    : incorrectCount == 3
                    ? 'assets/images/groupOfHeart3.png'  // Jika salah 3, gambar groupOfHeart4.png
                    : 'assets/images/groupOfHeart.png',  // Default gambar
                height: 40.0,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 40.0),
              ),
            ),
          ],
        ),


        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Center(
            child: Container(
              width: MediaQuery.of(context).size.shortestSide,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Color(0xFFF0F0F0),
                    ),
                  ),
                  Positioned(
                    top: 90,
                    left: 0,
                    right: 0,
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Menampilkan pertanyaan jika incorrectCount < 3
                            if (incorrectCount < 3) ...[
                              // Menampilkan teks pertanyaan
                              Text(
                                currentQuestion.question.questionText,
                                style: TextStyle(
                                  color: Color(0xFF343434),
                                  fontFamily: 'Hanken Grotesk',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(height: 16),

                              // Daftar pilihan
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: currentQuestion.question.choices.length,
                                itemBuilder: (context, index) {
                                  final choice = currentQuestion.question.choices[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedOptionIndex = index;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        backgroundColor: selectedOptionIndex == index
                                            ? Colors.green // Pilihan yang dipilih
                                            : const Color.fromARGB(255, 232, 223, 222), // Pilihan default
                                        side: BorderSide(color: Colors.white, width: 1),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          choice.choiceText,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 20),

                              // Tombol Check Answer
                              InkWell(
                                onTap: selectedOptionIndex != null
                                    ? () {
                                  final selectedChoice = currentQuestion.question.choices[selectedOptionIndex!];
                                  //print('ID Pilihan Terpilih: ${selectedChoice.id}');
                                  //print('Teks Pilihan Terpilih: ${selectedChoice.choiceText}');
                                  nextQuestion(currentQuestion.questionId, selectedChoice.id);
                                }
                                    : null,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                                    color: selectedOptionIndex != null
                                        ? Color(0xFF07840B) // Hijau jika pilihan dipilih
                                        : Colors.grey, // Abu-abu jika tidak ada pilihan
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text('Periksa Jawaban',
                                    style: TextStyle(
                                      fontFamily: 'Hanken Grotesk',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],

                            // Menampilkan pesan jika incorrectCount == 3
                            if (incorrectCount == 3) ...[
                              Center(
                                child: Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 16,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Menampilkan gambar di tengah
                                        Image.asset(
                                          'assets/images/groupOfHeart3.png',
                                          height: 40.0,
                                          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40.0),
                                        ),
                                        SizedBox(height: 16),

                                        // Menampilkan teks di tengah
                                        Text(
                                          'You\'ve lost all your hearts. Please start over.',
                                          style: TextStyle(
                                            color: Color(0xFF343434),
                                            fontFamily: 'Hanken Grotesk',
                                            fontSize: 20.0,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w400,
                                            height: 1.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 24),

                                        // Tombol Mulai Ulang di tengah
                                        ElevatedButton(
                                          onPressed: () {

                                            context.go(
                                              '/welcome-test?idrequest=${widget.idrequest ?? ''}&plantId=${widget.plantId?.toString() ?? ''}&plantName=${widget.plantName ?? ''}',
                                            );
                                            // Logika untuk mulai ulang
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0x8F0B0B),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                          ),
                                          child: Text(
                                            'Mulai Ulang',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]


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
    );
  }


}
