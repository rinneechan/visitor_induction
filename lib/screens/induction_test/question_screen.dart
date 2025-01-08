import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/QuestionRequestIdPlant.dart';

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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Box box; // Definisikan Box untuk Hive
  String? username;
  String? visitorid;
  String? email;
  ApiService apiService = ApiService();
  // Future<List<QuestionRequestIdPlant>>? futureQuestionrequest;
  List<QuestionRequestIdPlant> questionlist = [];

  bool _isLoading = false;

  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedOptionIndex;

  late Future<List<QuestionRequestIdPlant>>? futureQuestionrequest;
  List<QuestionRequestIdPlant> pertanyaan = [];
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

  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    final String plantid = widget.plantId;

    futureQuestionrequest = apiService.fetchQuestionrequestplant(plantid);
    futureQuestionrequest!.then((data) {
      setState(() {
        pertanyaan = data; // Simpan data ke variabel state
        _isLoading = false;
      });
      print('Data berhasil dimuat: ${pertanyaan.map((e) => e.toJson()).toList()}');
    }).catchError((error) {
      print('Error loading data: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> questions = [
    {
      'question':
          'Which of the following is NOT a recommended practice when working with hazardous chemicals in a plant site?',
      'options': [
        'Wearing appropriate Personal Protective Equipment (PPE)',
        'Reading the Safety Data Sheet (SDS) before handling',
        'Storing chemicals in unlabeled containers to save time',
        'Using proper ventilation in the work area'
      ],
      'answer': 'Storing chemicals in unlabeled containers to save time',
    },
    {
      'question':
          'True or False: It is acceptable to store chemicals in unlabeled containers to save time in a plant site?',
      'options': ['True', 'False'],
      'answer': 'False',
    },
    // Tambahkan soal lainnya di sini
  ];

  void nextQuestion() {
    if (selectedOptionIndex != null) {
      String correctAnswer = questions[currentQuestionIndex]['answer'];
      List<String> options =
          List<String>.from(questions[currentQuestionIndex]['options']);

      // Cek apakah jawabannya benar
      bool isCorrect = options[selectedOptionIndex!] == correctAnswer;

      // Tampilkan dialog untuk memberi tahu apakah jawaban benar atau salah
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isCorrect ? 'Correct!' : 'Wrong!'),
            content: Text(isCorrect
                ? 'You selected the correct answer!'
                : 'Sorry, that\'s not the correct answer.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  setState(() {
                    if (isCorrect) {
                      score++; // Tambah skor jika jawabannya benar
                    }

                    // Cek apakah ada soal berikutnya
                    if (currentQuestionIndex < questions.length - 1) {
                      currentQuestionIndex++; // Lanjut ke soal berikutnya
                    } else {
                      _showResult(); // Tampilkan hasil jika sudah selesai
                    }

                    selectedOptionIndex = null; // Reset pilihan
                  });
                },
                child: Text('Continue'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showResult() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Correct Answers',
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'You scored $score out of ${questions.length}!',
                style: TextStyle(fontSize: 16, fontFamily: 'Hanken Grotesk'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              score == questions.length
                  ? Text(
                      'Perfect score! Well done!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      'Keep practicing to improve your score.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07840B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text(
                  'Continue',
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
    // Saat masih loading, tampilkan indikator loading
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
    final currentQuestion = pertanyaan[questionIndex];
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Question ${questionIndex + 1} / ${questions.length}',
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
        ),
        body: Center(
            child: Container(
              width: MediaQuery.of(context).size.shortestSide,
              child: Stack(
                  children: <Widget>[
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              SizedBox(height: 1),
                              ListView(
                                shrinkWrap: true,
                                children: currentQuestion.question.choices.map<Widget>((choice) {
                                  return Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedOptionIndex = currentQuestion.question.choices.indexOf(choice);
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          backgroundColor: selectedOptionIndex ==
                                              currentQuestion.question.choices.indexOf(choice)
                                              ? Colors.green // Pilihan yang dipilih
                                              : const Color.fromARGB(255, 232, 223, 222), // Pilihan default
                                          side: BorderSide(
                                            color: Color(0xFFFFFF),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                choice!.choiceText,  // Pastikan properti ini sesuai dengan model Choice
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  );
                                }).toList(),
                              ),

                              SizedBox(height: 20),


                              InkWell(
                                onTap: selectedOptionIndex != null
                                    ? nextQuestion
                                    : null,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF07840B),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    'Check Answer',
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
      );
  }
}

// body: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// // Tampilkan pertanyaan saat ini
// Text(
// currentQuestion.question.questionText,
// style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// ),
// const SizedBox(height: 16),
// // Tampilkan pilihan jawaban
// ...currentQuestion.question.choices.map((choice) {
// return ListTile(
// title: Text(choice.choiceText),
// onTap: () {
// // Tindakan ketika pilihan dipilih
// print('Jawaban yang dipilih: ${choice.choiceText}');
// },
// );
// }).toList(),
// const SizedBox(height: 16),
// // Tombol untuk pertanyaan berikutnya
// ElevatedButton(
// onPressed: questionIndex < pertanyaan.length - 1
// ? () {
// setState(() {
// questionIndex++;
// });
// }
//     : null,
// child: const Text('Pertanyaan Berikutnya'),
// ),
// ],
// ),
//




