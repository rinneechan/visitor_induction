import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CreateNewPass extends StatefulWidget {
  final String employeeid;
  final String fullName;
  final String email;

  const CreateNewPass({super.key, required this.employeeid, required this.fullName, required this.email});

  @override
  _CreateNewPassState createState() => _CreateNewPassState();
}

class _CreateNewPassState extends State<CreateNewPass> {
  final TextEditingController _codeController = TextEditingController();

 // final _passwordController = TextEditingController();
  final bool _isButtonEnabled = false;
  final bool _isPasswordVisible = false;
  bool _isObscured = true;
  bool _isObscuredRe = true;

  bool _isDataVisible = true;
  bool _enterVerificationCode = false;
  bool _createNewPass = false;
  bool _successfullyPass = false;
  bool _isLoading = false;

  bool _isPasswordValid = false; // Cek apakah password valid
  bool _isRePasswordValid = false; // Cek apakah re-enter password valid
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  bool _isValidPassword(String password) {
    // Harus minimal 8 karakter, ada angka, dan ada simbol
    return RegExp(r'^(?=.*\d)(?=.*[\W_]).{8,}$').hasMatch(password);
  }

  @override
  void initState() {
    super.initState();
    // Tambahkan listener ke controller untuk mengecek setiap kali ada perubahan pada teks
    //passwordController.addListener(_checkIfButtonShouldBeEnabled);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  @override
  void _checkIfButtonShouldBeEnabled() {
    setState(() {
      // Aktifkan tombol jika kedua field (nik) tidak kosong
      //_isButtonEnabled = _passwordController.text.isNotEmpty;
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _isValidPassword(_passwordController.text);
      _isRePasswordValid = _passwordController.text == _rePasswordController.text;
    });
  }

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    ApiService apiService = ApiService(); // Buat instance ApiService
    final response = await apiService.generateCode(widget.employeeid, widget.fullName, widget.email);

    if (response != null && response['status'] == true) {
      setState(() {
        _enterVerificationCode = true;
        _isDataVisible = false;

        _enterVerificationCode = true;
        _isDataVisible = false;
        _createNewPass = false;
        _successfullyPass = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim kode verifikasi. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _verifyCode() async {
    if (_codeController.text.length == 6) {
      setState(() {
        _isLoading = true;
      });

      ApiService apiService = ApiService(); // Buat instance dari ApiService
      String idEmployee = widget.employeeid;
      String code = _codeController.text;

      final response = await apiService.verifyCode(idEmployee, code);

      setState(() {
        _isLoading = false;
        if (response != null) {
          _isDataVisible = false;
          _enterVerificationCode = false;
          _createNewPass = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kode verifikasi salah atau tidak valid')),
          );
        }
      });
    }
  }

  void _create_register() async {
    setState(() {
      _isLoading = true;
    });

    ApiService apiService = ApiService(); // Buat instance ApiService
    String passw = _passwordController.text;
    final response = await apiService.register(widget.employeeid, passw);

    if (response != null && response['status'].toString() == 'true') {
      setState(() {
        _enterVerificationCode = false;
        _isDataVisible = false;
        _createNewPass = false;
        _successfullyPass = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim kode verifikasi. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        GoRouter.of(context).go('/login'); // Navigasi ke halaman login
        return false; // Mencegah keluar dari aplikasi
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.asset(
                'assets/images/BackgroundVI.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Color.fromRGBO(0, 0, 0, 0.40),
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
                          crossAxisAlignment: CrossAxisAlignment.start, // Mengatur posisi teks ke kiri
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/logo-cg.svg',
                                  height: 30.0,
                                  width: 45.0,
                                  placeholderBuilder: (context) =>
                                      CircularProgressIndicator(),
                                ),
                                SizedBox(width: 10),
                                Image.asset('assets/images/Logo-badak.png',
                                  width: 40.0,
                                  height: 35.0,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 40.0),
                                ),
                              ],
                            ),
                            Text('Welcome!',
                              style: TextStyle(
                                fontSize: 32.0,
                                color: Color.fromARGB(255, 7, 132, 11),
                                fontFamily: 'Hanken Grotesk',
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 6), // Jarak antara dua teks

                            // Jarak antara dua teks
                            Text('Please provide your account details.',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 117, 117, 117), // Warna dari #757575
                                fontFamily:'Hanken Grotesk', // Font-family
                                fontSize: 14.0, // Ukuran font
                                fontStyle: FontStyle.normal, // Font-style normal
                                fontWeight: FontWeight.w400, // Berat font (400 = normal)
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
            SizedBox(height: 10),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: _isDataVisible,
                            child: Column(
                              children: [
                                SizedBox(height: 24),
                                Row(mainAxisAlignment: MainAxisAlignment.center, // Memposisikan teks di tengah
                                  children: [
                                    GestureDetector(
                                      child: Text(
                                        'ID has not been registered',
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 79, 77, 77),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(mainAxisAlignment: MainAxisAlignment.center, // Memposisikan teks di tengah
                                  children: [
                                    GestureDetector(
                                      child: Text(
                                        'Do you wish to continue using this ID?',
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 79, 77, 77),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0F0F0), // Warna background (Neutrals-100)
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Menyusun ke tengah
                                    crossAxisAlignment: CrossAxisAlignment.center, // Posisikan ke tengah
                                    children: [
                                      Text(
                                        widget.employeeid,
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 79, 77, 77),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          height: 1.0,
                                        ),
                                      ),
                                      SizedBox(height: 4), // Beri jarak antar teks
                                      Text(
                                        widget.fullName,
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 79, 77, 77),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.go('/login');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white, // Background putih
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          side: BorderSide(color: Color(0xFF07840B)), // Border hijau
                                        ),
                                        child: Text(
                                          'Change',
                                          style: TextStyle(
                                            color: Color(0xFF07840B), // Warna teks hijau
                                            fontFamily: 'Hanken Grotesk',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 16), // Jarak antar tombol
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _register,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF07840B), // Background hijau
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? CircularProgressIndicator(color: Colors.white)
                                            : Text('Register', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Visibility(
                            visible: _enterVerificationCode,
                            child: Column(
                              children: [
                                SizedBox(height: 24),
                                Row(mainAxisAlignment: MainAxisAlignment.center, // Memposisikan teks di tengah
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text('Enter Verification Code',
                                        style: TextStyle(
                                          color: Color(0xFF343434), // Warna sesuai dengan #343434
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.bold, // Sesuai dengan font-weight: 700
                                          height: 1.0, // Line-height 100% dari font size
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'We\'ve emailed a verification code to the address linked to your Employee ID.',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 79, 77, 77),
                                        fontFamily: 'Hanken Grotesk',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(mainAxisAlignment: MainAxisAlignment.center, // Memposisikan teks di tengah
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(widget.email,
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 79, 77, 77),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Form Password, Re-type Password, dan Tombol Set Password
                                TextField(
                                  controller: _codeController,
                                  //obscureText: _isObscured,
                                  keyboardType: TextInputType.number,
                                  //maxLength: 6,
                                  decoration: InputDecoration(
                                    labelText: 'Enter your verification code here',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 6) {
                                      _verifyCode();
                                    }
                                  },
                                ),
                                SizedBox(height: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Please wait 30s to resend',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 79, 77, 77),
                                        fontFamily: 'Hanken Grotesk',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),

                          Visibility(
                            visible: _createNewPass,
                            child: Column(
                              children: [
                                SizedBox(height: 24),
                                Row(mainAxisAlignment: MainAxisAlignment.center, // Memposisikan teks di tengah
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text('Create New Password',
                                        style: TextStyle(
                                          color: Color(0xFF343434), // Warna sesuai dengan #343434
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.bold, // Sesuai dengan font-weight: 700
                                          height: 1.0, // Line-height 100% dari font size
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Your registration is almost done, please set up a password to secure your account.',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 79, 77, 77),
                                        fontFamily: 'Hanken Grotesk',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Mengatur rata kiri
                                  children: [
                                    Text('Password',
                                      style: TextStyle(
                                        color: Color(0xFF343434),
                                        fontFamily: 'Hanken Grotesk',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: _isObscured,
                                      onChanged: (_) => _validatePassword(), // Panggil validasi saat input berubah
                                      decoration: InputDecoration(
                                        labelText: 'Enter Your Password',
                                        border: OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isObscured ? Icons.visibility_off : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isObscured = !_isObscured;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: _isPasswordValid ? Color(0xFF07840B) : Color(0xFFD1D1D1), // Warna hijau jika valid
                                        ),
                                        SizedBox(width: 8), // Jarak antara bullet dan teks
                                        Text('At least 8 characters',
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
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: _isPasswordValid ? Color(0xFF07840B) : Color(0xFFD1D1D1), // Warna hijau jika valid
                                        ),
                                        SizedBox(width: 8), // Jarak antara bullet dan teks
                                        Text('Mix of upper & lowercase',
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
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: _isPasswordValid ? Color(0xFF07840B) : Color(0xFFD1D1D1), // Warna hijau jika valid
                                        ),
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
                                SizedBox(height: 8),
                                TextField(
                                  controller: _rePasswordController,
                                  obscureText: _isObscuredRe,
                                  onChanged: (_) => _validatePassword(), // Panggil validasi saat input berubah
                                  decoration: InputDecoration(
                                    labelText: 'Re-enter your password',
                                    border: OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isObscuredRe ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isObscuredRe = !_isObscuredRe;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24), // Jarak sebelum tombol
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 30),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: (_isPasswordValid &&
                                            _isRePasswordValid &&
                                            _passwordController.text == _rePasswordController.text &&
                                            !_isLoading) // Tombol tidak bisa ditekan saat loading
                                            ? () {
                                          setState(() {
                                            _create_register();
                                          });
                                        }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: (_isPasswordValid &&
                                              _isRePasswordValid &&
                                              _passwordController.text == _rePasswordController.text)
                                              ? Color(0xFF07840B)
                                              : Color(0xFFA4A4A4),
                                          padding: EdgeInsets.symmetric(vertical: 16.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                            : Text(
                                          'Confirm Password',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Hanken Grotesk',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),




                              ],
                            ),
                          ),

                          Visibility(
                            visible: _successfullyPass,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/images/teenyicons_password-outline.png',
                                      width: 64.0,
                                      height: 64.0,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.broken_image, size: 40.0),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                Row(mainAxisAlignment: MainAxisAlignment.center, // Memposisikan teks di tengah
                                  children: [
                                    GestureDetector(
                                      child: Text(
                                        'Password Successfully Created',
                                        style: TextStyle(
                                          color: Color(0xFF343434), // Warna sesuai dengan --Neutrals-800-primary (#343434)
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 24.0,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w700, // Sama dengan font-weight: 700 (bold)
                                          height: 1.5, // Line-height normal (default)
                                          letterSpacing: 0.5, // Tidak ada jarak tambahan antar huruf
                                          decoration: TextDecoration.none,
                                        ),
                                        textAlign: TextAlign.center, // Sama dengan text-align: center
                                        softWrap: true,
                                        maxLines: null, // Batas maksimal 2 baris
                                        overflow: TextOverflow.ellipsis, // Tambahkan titik-titik jika teks terlalu panjang
                                      ),

                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Let’s login to your account.',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 79, 77, 77),
                                        fontFamily: 'Hanken Grotesk',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 24), // Jarak sebelum tombol

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 30), // Gap between buttons
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.go('/login');
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                          WidgetStateProperty.resolveWith<Color?>(
                                                (Set<WidgetState> states) {
                                              if (states.contains(WidgetState.disabled)) {
                                                return Color(
                                                    0xFFA4A4A4); // Warna saat tombol dinonaktifkan
                                              }
                                              return Color(
                                                  0xFF07840B); // Warna saat tombol aktif
                                            },
                                          ),
                                          padding: WidgetStateProperty.all<EdgeInsets>(
                                            EdgeInsets.symmetric(
                                                vertical:
                                                16.0), // Menyesuaikan padding agar tombol lebih tinggi
                                          ),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  8.0), // Sama dengan border-radius: 8px;
                                            ),
                                          ),
                                          foregroundColor:
                                          WidgetStateProperty.resolveWith<Color?>(
                                                (Set<WidgetState> states) {
                                              if (states.contains(WidgetState.disabled)) {
                                                return Colors
                                                    .white; // Warna teks saat tombol dinonaktifkan
                                              }
                                              return Colors
                                                  .white; // Warna teks saat tombol aktif
                                            },
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center, // Sama dengan justify-content: center;
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center, // Sama dengan align-items: center;
                                          children: [
                                            SizedBox(width: 10), // Sama dengan gap: 16px
                                            Text(
                                              'Back to login',
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
                                      ),
                                    ),
                                  ],
                                ),

                                // SizedBox(height: 10),
                                // TextField(
                                //   obscureText: _isObscuredRe,
                                //   decoration: InputDecoration(
                                //     labelText: 'Re-enter your password',
                                //     border: OutlineInputBorder(),
                                //   ),
                                // ),
                                // SizedBox(height: 24),
                                // ElevatedButton(
                                //   onPressed: () {
                                //     // Navigasi ke halaman selanjutnya atau proses lainnya
                                //   },
                                //   child: Text("Set Password"),
                                // ),
                              ],
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
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     extendBodyBehindAppBar: true,
  //
  //
  //   );
  // }
}
