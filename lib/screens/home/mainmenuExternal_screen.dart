import 'package:flutter/material.dart';
import 'custom_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

class MainmenuExternalScreen extends StatefulWidget {
  const MainmenuExternalScreen({Key? key}) : super(key: key);
  @override
  _MainmenuExternalScreenScreenState createState() => _MainmenuExternalScreenScreenState();
}

class _MainmenuExternalScreenScreenState extends State<MainmenuExternalScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Box box; // Definisikan Box untuk Hive
  String? username;
  String? visitorid;
  String? email;

  @override
  void initState() {
    super.initState();
    //_openBox();
  }
  void _loadData() {
    setState(() {
      //_isLoading = true;
    });
  }



  // Fungsi untuk mencegah back ke halaman sebelumnya
  Future<bool> _onWillPop() async {
    return true; // Mencegah navigasi ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Sedia',
            style: TextStyle(
              color: Color(0xFF07840B),
              fontFamily: 'Hanken Grotesk',
              fontSize: 32.323,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.normal,
              height: 1.0,
            ),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0, // Untuk membuat AppBar tanpa bayangan
        ),
        drawer: CustomDrawer(username: username),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.shortestSide,
            //height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                // Background Color
                Positioned.fill(
                  child: Container(
                    color: Color(0xFFF0F0F0), // Background aplikasi
                  ),
                ),

                // Card dengan teks dan dua opsi
                Positioned(
                  top: 90, // Posisikan Card di bagian atas layar
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
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Welcome Back, Visitor!',
                                style: TextStyle(
                                  color: Color(0xFF757575),
                                  fontFamily: 'Hanken Grotesk',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  height: 1.0,
                                ),
                              ),
                          ),
                          SizedBox(height: 16), // Jarak setelah teks

                          InkWell(
                            onTap: () {
                              context.go(
                                '/request-induction',
                                extra: {'username': username}, // Gunakan `extra` untuk mengirim data
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Visitor Induction',
                                        style: TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF343434),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                  SvgPicture.asset(
                                    'assets/images/Right-Scroll.svg',
                                    height: 40.0,
                                    width: 40.0,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 16),


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
