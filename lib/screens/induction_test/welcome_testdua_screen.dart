import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

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
  GlobalKey<ScaffoldState> _formKey_t2 = GlobalKey<ScaffoldState>();
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
    return WillPopScope(
      onWillPop: () async {
        // Prevent the user from navigating back
        return false;
      },
    child: Scaffold(
      key: _formKey_t2,
      appBar: AppBar(
        title: const Text(
          'INSTRUCTIONS',
          style: TextStyle(
            color: Color(0xFF07840B),
            fontFamily: 'Hanken Grotesk',
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            height: 1.0,
            textBaseline: TextBaseline.alphabetic,
            letterSpacing: 0.0,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center, // Teks rata tengah
          textScaleFactor: 1.0, // Untuk memastikan ukuran tetap konsisten

        ),

        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,

      ),

      body:Center(
        child: Container(

          width: MediaQuery.of(context).size.shortestSide,
          height: MediaQuery.of(context).size.height,
            child:SingleChildScrollView(
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
                Center(
                  child: _buildStartButton(),
                ),
              ],
            ),

          ),

        ),),
    ),
    );
  }

  Widget _buildInstructionCard__({
    required String iconPath,
    required String text,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(
              height: 58, // Sesuaikan ukuran sesuai kebutuhan
              width: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Warna border
                  width: 2.0,         // Ketebalan border
                ),
                borderRadius: BorderRadius.circular(8), // Radius border
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0), // Spasi dalam border
                child: SvgPicture.asset(
                  iconPath,
                  height: 40,
                  width: 40,
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
  Widget _buildInstructionCard({
    required String iconPath,
    required String text,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 24, // Tentukan tinggi minimal Card
        ),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(
              height: 58, // Sesuaikan ukuran sesuai kebutuhan
              width: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Warna border
                  width: 2.0,         // Ketebalan border
                ),
                borderRadius: BorderRadius.circular(8), // Radius border
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0), // Spasi dalam border
                child: SvgPicture.asset(
                  iconPath,
                  height: 40,
                  width: 40,
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
            // context.go(
            //   '/question',
            //   extra: {
            //     'idrequest': widget.idrequest,
            //     'plantId': widget.plantId, // Ganti idplant dengan plantId
            //     'plantName': widget.plantName,
            //   },
            // );
            context.go(
              '/question?idrequest=${widget.idrequest ?? ''}&plantId=${widget.plantId?.toString() ?? ''}&plantName=${widget.plantName ?? ''}',
            );


          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
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
