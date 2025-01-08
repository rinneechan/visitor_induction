import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Box box; // Definisikan Box untuk Hive
  String? username;
  String? visitorid;
  String? email;

  int currentQuestionIndex = 0;
  int score = 0;

  List<Map<String, Object>> questions = [
    {
      'question':
          'Which of the following is NOT a recommended practice when working with hazardous chemicals in a plant site?',
      'options': [
        'Wearing appropriate Personal Protective Equipment (PPE)',
        'Reading the Safety Data Sheet (SDS) before handling',
        'Storing chemicals in unlabeled containers to save time',
        'Using proper ventilation in the work area'
      ],
      'answer': 'Jakarta',
    },
    {
      'question':
          'True or False: It is acceptable to store chemicals in unlabeled containers to save time in a plant site.?',
      'options': ['True', 'False'],
      'answer': 'True',
    },
    // Tambahkan soal lainnya di sini
  ];

  void nextQuestion(String selectedOption) {
    String correctAnswer = questions[currentQuestionIndex]['answer'] as String;

    if (selectedOption == correctAnswer) {
      setState(() {
        score++;
      });
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) =>
      //         ResultScreen(score: score, total: questions.length),
      //   ),
      // );
    }
  }

  @override
  void initState() {
    super.initState();
    // Pastikan Hive sudah terbuka dan data diakses setelah box siap
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox'); // Buka box 'userBox'
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token'); // Ambil token

      // Jika token tidak ada, navigasi ke halaman login
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context,
            '/chooseaccess'); // Ganti '/login' dengan nama route halaman login
      } else {
        setState(() {});
      }
    });
  }

  // Fungsi untuk mencegah back ke halaman sebelumnya
  Future<bool> _onWillPop() async {
    return true; // Mencegah navigasi ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentQuestion = questions[currentQuestionIndex];
    List<String> optionLabels = ['A', 'B', 'C', 'D'];
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Question ${currentQuestionIndex + 1} / ${questions.length}',
            style: TextStyle(
              color: Color(0xFF343434),
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
              height: 1.0,
            ),
          ),
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 2,
        ),
        //drawer: CustomDrawer(username: username),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                color: Color(0xFFF0F0F0),
              ),
            ),

            // Card dengan teks dan dua opsi
            Positioned(
              top: 90,
              left: 0, // Padding kiri
              right: 0, // Padding kanan
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Border radius yang lebih baik
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
                        itemCount: currentQuestion['options'].length,
                        itemBuilder: (context, index) {
                          String option = currentQuestion['options'][index];
                          return Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => nextQuestion(option),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor:
                                      Color(0xFFFFFFFF), // Background putih
                                  side: BorderSide(
                                    color: Color(
                                        0xFFD1D1D1), // Border abu-abu ringan
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
                              SizedBox(height: 8), // Jarak antar tombol
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                    16), // Radius untuk sudut atas
                              ),
                            ),
                            builder: (BuildContext context) {
                              return Container(
                                height: MediaQuery.of(context).size.height *
                                    0.5, // Tinggi setengah layar
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Correct  ',
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
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Hanken Grotesk',
                                      ),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 24),
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
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF07840B), // Warna background tombol
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
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
                            ],
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
    );
  }
}
