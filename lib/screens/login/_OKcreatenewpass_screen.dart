import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OkCreateNewPass extends StatefulWidget {
  @override
  _OkCreateNewPassState createState() => _OkCreateNewPassState();
}

class _OkCreateNewPassState extends State<OkCreateNewPass> {
  //PersistentBottomSheetController? bottomSheetController;
  bool _isObscured = true;
  bool _isObscuredRe = true;

  @override
  void initState() {
    super.initState();
    // Memanggil modal bottom sheet otomatis ketika widget pertama kali dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Menjadikan modal bisa ditarik lebih tinggi
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),

        builder: (BuildContext context) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40), // Terapkan sudut bulat pada konten
              topRight: Radius.circular(40),
            ),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20), // Menambahkan padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Menyesuaikan ukuran berdasarkan konten
                children: [
                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Memposisikan teks di tengah
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman CreateNewPass
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OkCreateNewPass()),
                          );
                        },
                        child: Text(
                          'Create New Password',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 79, 77, 77),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Memposisikan teks di tengah
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman CreateNewPass
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OkCreateNewPass()),
                          );
                        },
                        child: Text(
                          'Your registration is almost done.',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 79, 77, 77),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Memposisikan teks di tengah
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman CreateNewPass
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OkCreateNewPass()),
                          );
                        },
                        child: Text(
                          'Please set up a password to secure your account.',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 79, 77, 77),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Text(
                    'Password',
                    style: TextStyle(
                      color: Color(0xFF343434),
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 16.0, // Ukuran font
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 10),

                  TextField(
                    obscureText:
                        _isObscured, // Menyembunyikan atau menampilkan password
                    decoration: InputDecoration(
                      labelText: 'Enter Your Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_off
                              : Icons.visibility, // Ikon mata
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured =
                                !_isObscured; // Mengubah status visibility
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle,
                              size: 8,
                              color: Color(0xFFD1D1D1)), // Bullet point
                          SizedBox(width: 8), // Jarak antara bullet dan teks
                          Text(
                            'At least 8 characters',
                            style: TextStyle(
                              color: Color(0xFF343434),
                              fontFamily: 'Hanken Grotesk',
                              fontSize: 14.0, // Ukuran font
                              fontWeight: FontWeight.normal,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8), // Jarak antar item
                      Row(
                        children: [
                          Icon(Icons.circle,
                              size: 8,
                              color: Color(0xFFD1D1D1)), // Bullet point
                          SizedBox(width: 8), // Jarak antara bullet dan teks
                          Text(
                            'Mix of upper & lowercase',
                            style: TextStyle(
                              color: Color(0xFF343434),
                              fontFamily: 'Hanken Grotesk',
                              fontSize: 14.0, // Ukuran font
                              fontWeight: FontWeight.normal,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.circle,
                              size: 8,
                              color: Color(0xFFD1D1D1)), // Bullet point
                          SizedBox(width: 8), // Jarak antara bullet dan teks
                          Text(
                            'Include a number and symbol',
                            style: TextStyle(
                              color: Color(0xFF343434),
                              fontFamily: 'Hanken Grotesk',
                              fontSize: 14.0, // Ukuran font
                              fontWeight: FontWeight.normal,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  Text(
                    'Re-type Password',
                    style: TextStyle(
                      color: Color(0xFF343434),
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 16.0, // Ukuran font
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),

                  SizedBox(height: 8),
                  TextField(
                    obscureText: _isObscuredRe,
                    decoration: InputDecoration(
                      labelText: 'Re-enter your password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscuredRe
                              ? Icons.visibility_off
                              : Icons.visibility, // Ikon mata
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscuredRe =
                                !_isObscuredRe; // Mengubah status visibility
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 24), // Jarak sebelum tombol

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: 30), // Gap between buttons
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigasi kembali ke halaman sebelumnya
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Sama dengan justify-content: center;
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Sama dengan align-items: center;
                            children: [
                              SizedBox(width: 10), // Sama dengan gap: 16px
                              Text(
                                'Set Password',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                      255, 79, 77, 77), // Warna dari #757575
                                  fontFamily: 'Hanken Grotesk', // Font-family
                                  fontSize: 16.0, // Ukuran font
                                  fontStyle:
                                      FontStyle.normal, // Font-style normal
                                  fontWeight: FontWeight
                                      .w400, // Berat font (400 = normal)
                                  height: 1.0, // Line-height (normal)
                                ),
                              ),
                            ],
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Color(
                                      0xFFA4A4A4); // Warna saat tombol dinonaktifkan
                                }
                                return Color(
                                    0xFF07840B); // Warna saat tombol aktif
                              },
                            ),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.symmetric(
                                  vertical:
                                      16.0), // Menyesuaikan padding agar tombol lebih tinggi
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Sama dengan border-radius: 8px;
                              ),
                            ),
                            foregroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors
                                      .white; // Warna teks saat tombol dinonaktifkan
                                }
                                return Colors
                                    .white; // Warna teks saat tombol aktif
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sedia',
              style: TextStyle(
                fontSize: 32.3,
                fontWeight: FontWeight.w900,
                color: Color(0xFFA4A4A4),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
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
              'assets/images/BackgroundSedia.png', // Pastikan gambar ini sudah ada di folder assets
              fit: BoxFit.cover, // Mengatur gambar agar memenuhi layar
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
                            'Welcome to',
                            style: TextStyle(
                              fontSize: 40.0,
                              color: Color.fromARGB(255, 7, 132, 11),
                              fontFamily: 'Hanken Grotesk',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'SEDIA Apps',
                            style: TextStyle(
                              fontSize: 40.0,
                              color: Color.fromARGB(255, 7, 132, 11),
                              fontFamily: 'Hanken Grotesk',
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                          SizedBox(height: 16), // Jarak antara dua teks

                          // Jarak antara dua teks
                          Text(
                            'Please provide your account details.',
                            style: TextStyle(
                              color: const Color.fromARGB(
                                  255, 117, 117, 117), // Warna dari #757575
                              fontFamily: 'Hanken Grotesk', // Font-family
                              fontSize: 16.0, // Ukuran font
                              fontStyle: FontStyle.normal, // Font-style normal
                              fontWeight:
                                  FontWeight.w400, // Berat font (400 = normal)
                              height: 1.0, // Line-height (normal)
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
        ],
      ),
    );
  }
}
