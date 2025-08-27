import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';

class RequestInductionScreen extends StatelessWidget {
  const RequestInductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visitor Induction")),
      drawer: const CustomDrawer(username: "Guest"), // Drawer opsional
      body: Column(
        children: [
          // Bagian atas sticky
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07840B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Navigasi ke form induction
                      context.go('/request-form');
                    },
                    child: const Text(
                      "REQUEST NEW INDUCTION",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider tipis sebagai pemisah
          const Divider(height: 1, thickness: 0.8),

          // Expanded supaya list scrollable
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Header Material
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: const [
                        Icon(Icons.assignment, color: Colors.black54),
                        SizedBox(width: 8),
                        Text(
                          "Induction Material",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List Material
                SliverList(
                  delegate: SliverChildListDelegate(
                    const [
                      _MaterialItem(title: "Material #1"),
                      _MaterialItem(title: "Material #2"),
                      _MaterialItem(title: "Material #3"),
                      _MaterialItem(title: "Material #4"),
                    ],
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

class _MaterialItem extends StatelessWidget {
  final String title;

  const _MaterialItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: TextButton.icon(
          onPressed: () {
            // TODO: aksi download file
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Download $title belum tersedia")),
            );
          },
          icon: const Icon(Icons.download, size: 18, color: Color(0xFF07840B)),
          label: const Text(
            "Download",
            style: TextStyle(
              color: Color(0xFF07840B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
