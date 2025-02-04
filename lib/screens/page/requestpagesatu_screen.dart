import 'package:flutter/material.dart';
import '../home/custom_drawer.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
class ReqPageSatu extends StatefulWidget {
  @override
  _ReqPageSatuScreenState createState() => _ReqPageSatuScreenState();
}

class _ReqPageSatuScreenState extends State<ReqPageSatu> {
  late Box box;
  String? username;
  String? visitorid;
  String? emailuser;

  final _emailController = TextEditingController();
  final _companynameController = TextEditingController();
  final _jobpositionController = TextEditingController();
  //bool _isEmailValid = true;
  bool _isButtonNextEnabled = true;
  //bool _isLoading = false;

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
      emailuser = box.get('email');
      String? token = box.get('token');
      // Jika token tidak ada, navigasi ke halaman login
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context,
            '/chooseaccess'); // Ganti '/login' dengan nama route halaman login
      } else {
        // Jika token ada, setState untuk memperbarui UI
        setState(() {
          //_loadData();
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _companynameController.dispose();
    _jobpositionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Visitor Induction',
          style: TextStyle(
            color: Color(0xFF343434), // Warna teks sesuai dengan #343434
            fontFamily: 'Hanken Grotesk', // Nama font
            fontSize: 20.0, // Ukuran font
            fontWeight: FontWeight.w700, // Tebal font (700)
            fontStyle: FontStyle.normal, // Gaya font normal
            height: 1.0, // Line-height (100%)
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 2,
      ),
      drawer: CustomDrawer(),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 100.0), // Jaga jarak dari tombol bawah
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0), // Posisi card di bagian atas
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  child: IconButton(
                                    icon: Image.asset(
                                      'assets/images/mdi_paper-check-outline.png',
                                      width: 50.0,
                                      height: 50.0,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),
                            Text(
                              'Assessment Request Submitted Successfully',
                              style: TextStyle(
                                color: Color(0xFF343434),
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 24.0,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your request has been received. SHE Admin or HR Plant will review it, which may take some time. We ll email you with updates. Thank you for your patience.',
                              style: TextStyle(
                                color: Color(0x75757575),
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Please kindly check your email:',
                              style: TextStyle(
                                color: Color(0x75757575),
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '$emailuser',
                              style: TextStyle(
                                color: Color(0x75757575),
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                height: 1.0,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white, // Latar belakang putih
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Next button
                    Expanded(
                      child: ElevatedButton(
                        //onPressed: _isButtonNextEnabled ? _next : null,
                        onPressed: () {
                          context.go(
                            '/request-induction',
                            extra: {'username': username},
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            Text(
                              'Back to Main Menu',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 79, 77, 77),
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07840B),
                          padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding vertikal dalam tombol
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
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
    );
  }
}
