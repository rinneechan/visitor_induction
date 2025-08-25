import 'package:flutter/material.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';
import 'package:she_vi/screens/home/external/request_induction_form_screen.dart';


class RequestInductionScreen extends StatefulWidget {
  final String? username;
  const RequestInductionScreen({super.key, this.username});

  @override
  State<RequestInductionScreen> createState() => _RequestInductionScreenState();
}

class _RequestInductionScreenState extends State<RequestInductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitor Induction"),
      ),
      drawer: CustomDrawer(username: widget.username ?? "Guest"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "Click the button below to schedule your visitor induction.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Arahkan ke form request induction
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "REQUEST NEW INDUCTION",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Row(
              children: [
                Icon(Icons.assignment, color: Colors.black54),
                SizedBox(width: 8),
                Text(
                  "Induction Material",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMaterialItem("Material #1"),
            _buildMaterialItem("Material #2"),
            _buildMaterialItem("Material #3"),
            _buildMaterialItem("Material #4"),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(title),
        trailing: TextButton(
          onPressed: () {
            // TODO: aksi download file
          },
          child: const Text(
            "Download",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
