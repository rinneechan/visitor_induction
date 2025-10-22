import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';

class RequestInductionScreen extends StatelessWidget {
  const RequestInductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Visitor Induction",
          style: TextStyle(
            color: Color(0xFF343434),
            fontFamily: "Hanken Grotesk",
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: const CustomDrawer(username: "Guest"),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.shortestSide,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Column(
                        children: [
                          _buildTopSection(context),
                          const Divider(height: 1, thickness: 0.8),
                          _buildMaterialList(),
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

  /// Bagian atas dengan tombol "Request New Induction"
  Widget _buildTopSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Click the button below to schedule your visitor induction.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "HankenGrotesk",
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 280, // fixed width
            height: 44, // fixed height agar proporsional
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF07840B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                context.go('/request-form');
              },
              child: const Text(
                "REQUEST NEW INDUCTION",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bagian daftar induction material
  Widget _buildMaterialList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Image.asset(
                "assets/images/ri_presentation-line.png", // icon sesuai figma
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Induction Material",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const _MaterialItem(title: "Material #1"),
        const _MaterialItem(title: "Material #2"),
        const _MaterialItem(title: "Material #3"),
        const _MaterialItem(title: "Material #4"),
      ],
    );
  }
}

class _MaterialItem extends StatelessWidget {
  final String title;

  const _MaterialItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Download $title belum tersedia")),
                );
              },
              child: const Text(
                "Download",
                style: TextStyle(
                  color: Color(0xFF07840B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
