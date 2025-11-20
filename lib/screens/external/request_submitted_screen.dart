import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestSubmittedScreen extends StatelessWidget {
  final String email;

  const RequestSubmittedScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Visitor Induction",
          style: GoogleFonts.hankenGrotesk(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: CustomDrawer(username: "Guest"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // biar center sesuai konten
            crossAxisAlignment: CrossAxisAlignment.start, // teks & icon rata kiri
            children: [
              // Icon dokumen
              Image.asset(
                "assets/images/mdi_paper-check-outline.png",
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 30),

              // Judul
              Text(
                "Assessment Request\nSubmitted Successfully",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Deskripsi
              Text(
                "Your request has been received. SHE Admin or HR Plant will review it, which may take some time. "
                "We'll email you with updates. Thank you for your patience.",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Please kindly check your email:",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: GoogleFonts.hankenGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Tombol fixed width & center
              Center(
                child: SizedBox(
                  width: 320,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      context.go("/main-menu-ext");
                    },
                    child: Text(
                      "BACK TO MAIN MENU",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
