import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
//import '../induction_test/welcome_testdua_screen.dart';

class WelcomeTestSatuScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;

  const WelcomeTestSatuScreen({
    Key? key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
  }) : super(key: key);

  @override
  _WelcomeTestSatuScreenState createState() => _WelcomeTestSatuScreenState();
}

class _WelcomeTestSatuScreenState extends State<WelcomeTestSatuScreen> {
  late Box box;
  String? username;
  String? visitorid;
  String? email;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token');

      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/chooseaccess');
      }
    });
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: _buildAppBarContent(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset('assets/images/logo-cg.svg', height: 40),
        Text(
          'CEMINDO GEMILANG',
          style: const TextStyle(
            fontSize: 11.429,
            fontWeight: FontWeight.w800,
            color: Color(0xFFB0191F),
            fontFamily: 'Lato',
          ),
        ),
        Image.asset('assets/images/logo-sedia.png', height: 80),
      ],
    );
  }

  Widget _buildBody() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.shortestSide,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(color: Color(0xFFF0F0F0)),
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildUserGreeting(),
                      const SizedBox(height: 24),
                      _buildCG(),
                      const SizedBox(height: 24),
                      _buildPlantInfo(),
                      const SizedBox(height: 24),
                      _buildInstructions(),
                      const SizedBox(height: 24),
                      _buildDownloadButton(),
                      const SizedBox(height: 24),
                      _buildConfirmationButton(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Divider(color: Color(0xFF07840B), thickness: 1.0),
        const SizedBox(height: 8),
        Text(
          'VISITOR INDUCTIONS',
          style: const TextStyle(
            color: Color(0xFF07840B),
            fontFamily: 'Hanken Grotesk',
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: Color(0xFF07840B), thickness: 1.0),
      ],
    );
  }

  Widget _buildUserGreeting() {
    return username == null
        ? const CircularProgressIndicator()
        : Text(
            'Hello, $username',
            style: const TextStyle(
              color: Color(0xFF757575),
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          );
  }

  Widget _buildCG() {
    return Text(
      'WELCOME TO\nPT CEMINDO GEMILANG TBK',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF343434),
        fontFamily: 'Hanken Grotesk',
        fontSize: 20.0,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
        height: 1.0,
      ),
    );
  }

  Widget _buildPlantInfo() {
    return Text(
      widget.plantName,
      style: const TextStyle(
        color: Color(0xFF757575),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildInstructions() {
    return Text(
      'Before taking your access pass test, please download and read our safety materials to fully understand the safety rules at our plant sites.',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF343434),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }

  Widget _buildDownloadButton() {
    return InkWell(
      onTap: () {
        // TODO: Tambahkan logika unduh material
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Download Induction Material',
            style: TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF07840B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationButton() {
    return InkWell(
      onTap: () {
        print('Sending test satu: ${widget.plantId}');
        Navigator.pushNamed(
          context,
          '/welcome-test-intructions',
          arguments: {
            'idrequest': widget.idrequest,
            'plantId': widget.plantId.toString(),
            'plantName': widget.plantName,
          },
        );
      },
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          color: Color(0xFF07840B),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Text(
            'I have read and understood the safety rules of the plant sites.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
