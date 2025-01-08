import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChooseAccess extends StatefulWidget {
  @override
  _ChooseAccessScreenState createState() => _ChooseAccessScreenState();
}

class _ChooseAccessScreenState extends State<ChooseAccess> {
  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sedia', // Teks di sebelah logo
              style: TextStyle(
                fontSize: 32.323, // Ukuran font
                fontWeight: FontWeight.w900, // Berat font
                color: Color(0xFFA4A4A4), // Warna placeholder
                height: 1.0, // Line-height
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min, // Important to limit width
              children: [
                SvgPicture.asset(
                  'assets/images/logo-cg.svg',
                  height: 40,
                ),
                SizedBox(width: 10),
                Image.asset(
                  'assets/images/Logo-badak.png',
                  height: 40,
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/BackgroundSedia.png',
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 100.0,
                        left: 24.0,
                        right: 15.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Mengatur posisi teks ke kiri
                        children: [
                          Text(
                            'Are you CG',
                            style: TextStyle(
                              fontSize: 40.0,
                              color: Color.fromARGB(255, 7, 132, 11),
                              fontFamily: 'Hanken Grotesk',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Employee?',
                            style: TextStyle(
                              fontSize: 40.0,
                              color: Color.fromARGB(255, 7, 132, 11),
                              fontFamily: 'Hanken Grotesk',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Select one option from the list below.',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 117, 117, 117),
                              fontFamily: 'Hanken Grotesk',
                              fontSize: 16.0,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Column(
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row pertama dengan border dan gesture handler (InkWell)
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0), // Garis sekeliling
                              borderRadius: BorderRadius.circular(
                                  10), // Membuat border melengkung
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  8.0), // Padding dalam Container
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CG Employee',
                                        style: TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF343434),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Login with your Employee ID.',
                                        style: TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
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
                        ),
                        SizedBox(
                            height: 10), // Jarak antara Row pertama dan kedua

                        // Row kedua dengan border dan gesture handler (InkWell)
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/externalVisitor');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0), // Garis sekeliling
                              borderRadius: BorderRadius.circular(
                                  10), // Membuat border melengkung
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  8.0), // Padding dalam Container
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'External Visitor',
                                        style: TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF343434),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Provide with your details.',
                                        style: TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
