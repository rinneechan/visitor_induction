import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

class WelcomeTestDuaScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;

  const WelcomeTestDuaScreen({
    Key? key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
  }) : super(key: key);

  @override
  _WelcomeTestDuaScreenState createState() => _WelcomeTestDuaScreenState();
}

class _WelcomeTestDuaScreenState extends State<WelcomeTestDuaScreen> {
  late Box box;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    setState(() {
      String? token = box.get('token');
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/chooseaccess');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'INSTRUCTIONS',
          style: TextStyle(
            color: Color(0xFF343434),
            fontFamily: 'Hanken Grotesk',
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildInstructionCard(
                iconPath: 'assets/images/heart.svg',
                text: 'You start with 3 hearts.',
              ),
              const SizedBox(height: 16),
              _buildInstructionCard(
                iconPath: 'assets/images/reset.svg',
                text: 'If you lose all your hearts, your progress will reset, and you\'ll have to start over.',
              ),
              const SizedBox(height: 16),
              _buildInstructionCard(
                iconPath: 'assets/images/badge.svg',
                text: 'Once you complete the assessment, you\'ll receive an Access Badge valid for the requested period.',
              ),
              const SizedBox(height: 32),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard({
    required String iconPath,
    required String text,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF343434),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStartButton() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: () {

            print('Sending  test dua: ${widget.plantId}');
            Navigator.pushNamed(
              context,
              '/question',
              arguments: {
                'idrequest': widget.idrequest,
                'plantId': widget.plantId, // Ganti idplant dengan plantId
                'plantName': widget.plantName,
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF07840B),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(
              child: Text(
                'Start Induction Test',
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
