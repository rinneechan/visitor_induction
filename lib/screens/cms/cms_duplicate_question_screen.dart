import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/models/mc_question.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';

class CmsDuplicateQuestionScreen extends StatefulWidget {
  final MCQuestion question;
  const CmsDuplicateQuestionScreen({Key? key, required this.question})
      : super(key: key);

  @override
  State<CmsDuplicateQuestionScreen> createState() =>
      _CmsDuplicateQuestionScreenState();
}

class _CmsDuplicateQuestionScreenState
    extends State<CmsDuplicateQuestionScreen> {
  String? selectedPlant;
  final List<Map<String, dynamic>> availablePlants = [
    {"id": 1, "name": "Bayah Plant"},
    {"id": 2, "name": "Ciwandan Plant"},
    {"id": 3, "name": "Cibitung Plant"},
  ];

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _duplicateQuestion() async {
    if (selectedPlant == null) {
      _showSnack("Pilih plant tujuan terlebih dahulu.");
      return;
    }

    // TODO: sambungkan ke backend (POST /duplicate-question)
    _showSnack("✅ Soal berhasil diduplikat ke $selectedPlant (dummy).");
    Navigator.pop(context, true);
  }

  void _goBackToCms() {
    // Kirim plantId sebagai String sesuai GoRoute '/cms' yang mengharapkan state.extra sebagai String
    final plantIdStr = widget.question.plantId.toString();
    context.go('/cms', extra: plantIdStr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(username: "Admin CMS"),
      appBar: AppBar(
        title: Text(
          "Duplicate Soal",
          style: GoogleFonts.hankenGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF07840B),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detail Soal yang Akan Diduplikat",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.question.question),
                const SizedBox(height: 8),
                if (widget.question.optionA != null)
                  Text("A. ${widget.question.optionA}"),
                if (widget.question.optionB != null)
                  Text("B. ${widget.question.optionB}"),
                if (widget.question.optionC != null)
                  Text("C. ${widget.question.optionC}"),
                if (widget.question.optionD != null)
                  Text("D. ${widget.question.optionD}"),
                const SizedBox(height: 8),
                Text(
                  "Jawaban Benar: ${widget.question.correctAnswer ?? '-'}",
                  style: const TextStyle(color: Colors.green),
                ),
                const Divider(height: 32),
                const Text(
                  "Pilih Plant Tujuan:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedPlant,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Pilih Plant",
                  ),
                  items: availablePlants
                      .map(
                        (p) => DropdownMenuItem<String>(
                          value: p["name"],
                          child: Text(p["name"]),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedPlant = val),
                ),
                const SizedBox(height: 24),

                /// Tombol Back (lingkaran hijau) + Duplikat Soal (kanan)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Back berbentuk lingkaran hijau
                    ElevatedButton(
                      onPressed: _goBackToCms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07840B),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                        elevation: 3,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),

                    const SizedBox(width: 12),

                    // Tombol Duplikat Soal di kanan (expand agar tetap lebar)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _duplicateQuestion,
                        icon: const Icon(Icons.copy, color: Colors.white),
                        label: const Text(
                          "Duplikat Soal",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
