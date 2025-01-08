import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  final String idrequest;
  final String plantName;

  const QuestionScreen({
    Key? key,
    required this.idrequest,
    required this.plantName,
  }) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  int?
      selectedOptionIndex; // Variabel untuk menyimpan indeks pilihan yang dipilih

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
    Map<String, dynamic> currentQuestion = questions[currentQuestionIndex];
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
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
                  top: 20,
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
                            currentQuestion['question'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                (currentQuestion['options'] as List<String>)
                                    .length,
                            itemBuilder: (context, index) {
                              String option = (currentQuestion['options']
                                  as List<String>)[index];
                              return Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedOptionIndex =
                                            index; // Simpan pilihan
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: selectedOptionIndex ==
                                              index
                                          ? Colors.green // Pilihan yang benar
                                          : const Color.fromARGB(255, 232, 223,
                                              222), // Pilihan yang salah
                                      side: BorderSide(
                                        color: Color(0xFFD1D1D1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          // InkWell(
                          //   onTap: selectedOptionIndex != null
                          //       ? nextQuestion
                          //       : null,
                          //   child: Container(
                          //     width: double.infinity,
                          //     padding: const EdgeInsets.all(24.0),
                          //     decoration: BoxDecoration(
                          //       color: Color(0xFF07840B),
                          //       borderRadius: BorderRadius.circular(8.0),
                          //     ),
                          //     child: Text(
                          //       'Check Answer',
                          //       style: TextStyle(
                          //         fontFamily: 'Hanken Grotesk',
                          //         fontSize: 16.0,
                          //         fontWeight: FontWeight.w700,
                          //         color: Colors.white,
                          //         height: 1.2,
                          //       ),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),
                          // ),

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
