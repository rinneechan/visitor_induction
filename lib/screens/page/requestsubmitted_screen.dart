import 'package:flutter/material.dart';
import '../home/custom_drawer.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

class RequestSubmitted extends StatefulWidget {
  final String username;

  const RequestSubmitted({super.key, required this.username});

  @override
  State<RequestSubmitted> createState() => _RequestSubmittedScreenState();
}

class _RequestSubmittedScreenState extends State<RequestSubmitted> {
  late Box box;
  String? username;
  String? visitorid;
  String? emailuser;

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
      emailuser = box.get('email');
      final String? token = box.get('token');

      if (token == null || token.isEmpty) {
        context.go('/choose-access');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visitor Induction',
          style: TextStyle(
            color: Color(0xFF343434),
            fontFamily: 'Hanken Grotesk',
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: CustomDrawer(username: username ?? "Guest"),
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Container(color: Colors.white),
            ),

            // Konten utama
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: IconButton(
                            icon: Image.asset(
                              'assets/images/mdi_paper-check-outline.png',
                              width: 50.0,
                              height: 50.0,
                            ),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Assessment Request Submitted Successfully',
                          style: TextStyle(
                            color: Color(0xFF343434),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your request has been received. SHE Admin or HR Plant will review it, which may take some time. We\'ll email you with updates. Thank you for your patience.',
                          style: TextStyle(
                            color: Color(0x75757575),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Please kindly check your email:',
                          style: TextStyle(
                            color: Color(0x75757575),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          emailuser ?? '—',
                          style: const TextStyle(
                            color: Color(0x75757575),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tombol di bawah
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/employee/request-induction',
                        extra: {'username': username ?? 'defaultID'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07840B),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text(
                    'Back to Main Menu',
                    style: TextStyle(
                      color: Colors.white, // ✅ Putih, bukan abu-abu
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
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
