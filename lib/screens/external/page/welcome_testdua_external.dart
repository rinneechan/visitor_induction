import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

class WelcomeTestDuaExternalScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;
  final String urlakses;

  const WelcomeTestDuaExternalScreen({
    super.key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
    required this.urlakses,
  });

  @override
  _WelcomeTestDuaExternalScreenState createState() =>
      _WelcomeTestDuaExternalScreenState();
}

class _WelcomeTestDuaExternalScreenState
    extends State<WelcomeTestDuaExternalScreen> {
  late Box box;

  @override
  void initState() {
    super.initState();
    //_openBox();
  }

  Future<void> _openBox() async {
    // External tidak butuh token login, tapi box tetap perlu dibuka
    box = await Hive.openBox('userBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INSTRUCTIONS'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF07840B),
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionCard(
                    iconPath: 'assets/images/heart.svg',
                    text: 'You start with 3 hearts.',
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionCard(
                    iconPath: 'assets/images/reset.svg',
                    text:
                        'If you lose all your hearts, your progress will reset, and you\'ll have to start over.',
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionCard(
                    iconPath: 'assets/images/badge.svg',
                    text:
                        'Once you complete the assessment, you\'ll receive an Access Badge valid for the requested period.',
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _buildStartButton(),
                  ),
                ],
              ),
            ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: SvgPicture.asset(
                  iconPath,
                  fit: BoxFit.contain,
                ),
              ),
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
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        context.go(
          '/external/induction/question'
          '?idrequest=${Uri.encodeComponent(widget.idrequest)}'
          '&plantId=${Uri.encodeComponent(widget.plantId)}'
          '&plantName=${Uri.encodeComponent(widget.plantName)}'
          '&urlakses=${Uri.encodeComponent(widget.urlakses)}',
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF07840B),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Start Induction Test',
        style: TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );
}
}
