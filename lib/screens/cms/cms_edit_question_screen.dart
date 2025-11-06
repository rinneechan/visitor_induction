import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/models/mc_question.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';

class CmsEditQuestionScreen extends StatefulWidget {
  final MCQuestion question;
  const CmsEditQuestionScreen({Key? key, required this.question})
      : super(key: key);

  @override
  State<CmsEditQuestionScreen> createState() => _CmsEditQuestionScreenState();
}

class _CmsEditQuestionScreenState extends State<CmsEditQuestionScreen> {
  late TextEditingController _questionController;
  late TextEditingController _explanationController;
  late List<TextEditingController> _optionControllers;
  String? _correctAnswer;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.question);
    _explanationController =
        TextEditingController(text: widget.question.correctAnswer ?? "");
    _optionControllers = [
      TextEditingController(text: widget.question.optionA ?? ''),
      TextEditingController(text: widget.question.optionB ?? ''),
      TextEditingController(text: widget.question.optionC ?? ''),
      TextEditingController(text: widget.question.optionD ?? ''),
    ];
    _correctAnswer = widget.question.correctAnswer;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (var c in _optionControllers) c.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _saveEditedQuestion() async {
    // TODO: sambungkan ke backend (PUT /update-question)
    _showSnack("✅ Soal berhasil diperbarui (dummy).");
    // sementara arahkan balik ke CMS
    context.go('/cms', extra: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(username: "Admin CMS"),
      appBar: AppBar(
        title: Text(
          "Edit Soal",
          style: GoogleFonts.hankenGrotesk(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF07840B),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Edit Pertanyaan",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _questionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Masukkan pertanyaan baru",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Edit Opsi Jawaban"),
                const SizedBox(height: 8),
                for (int i = 0; i < 4; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: _optionControllers[i].text,
                          groupValue: _correctAnswer,
                          onChanged: (val) =>
                              setState(() => _correctAnswer = val),
                          activeColor: const Color(0xFF07840B),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _optionControllers[i],
                            decoration: InputDecoration(
                              labelText: "Opsi ${String.fromCharCode(65 + i)}",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                const Text("Penjelasan (opsional)"),
                const SizedBox(height: 8),
                TextField(
                  controller: _explanationController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Masukkan penjelasan",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // === Tombol di bagian bawah ===
              Row(
            children: [
              // Tombol Back Bulat Kecil
            InkWell(
            onTap: () => context.go('/cms', extra: ''),
             borderRadius: BorderRadius.circular(50), 
            child: Container(
            width: 36, 
            height: 36,
            decoration: const BoxDecoration(
          color: Color(0xFF07840B),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
      ),
    ),
    const SizedBox(width: 12),
                    // Tombol Simpan Perubahan
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveEditedQuestion,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Simpan Perubahan",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07840B),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
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
