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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Request New Induction
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.push('/request-form'); 
                  // Pastikan sudah ada GoRoute dengan path: '/request-form'
                  // dan builder-nya mengarah ke RequestInductionFormScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "REQUEST NEW INDUCTION",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Header Material
            const Row(
              children: [
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

            const SizedBox(height: 16),

            // List Material
            const _MaterialItem(title: "Material #1"),
            const _MaterialItem(title: "Material #2"),
            const _MaterialItem(title: "Material #3"),
            const _MaterialItem(title: "Material #4"),
          ],
        ),
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
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(title),
        trailing: TextButton(
          onPressed: () {
            // TODO: aksi download file
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Download $title belum tersedia")),
            );
          },
          child: const Text(
            "Download",
            style: TextStyle(
              color: Colors.green, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
