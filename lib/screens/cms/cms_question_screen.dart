import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/models/mc_question.dart';
import 'package:she_vi/services/api_service.dart';

class CmsQuestionScreen extends StatefulWidget {
  final String plantId;
  const CmsQuestionScreen({Key? key, required this.plantId}) : super(key: key);

  @override
  State<CmsQuestionScreen> createState() => _CmsQuestionScreenState();
}

class _CmsQuestionScreenState extends State<CmsQuestionScreen> {
  final ApiService api = ApiService();

  String questionType = "Multiple Choice";

  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  String _trueFalseAnswer = "True";

  List<MCQuestion> questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestionsFromBackend();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) c.dispose();
    super.dispose();
  }

 /// --- Load soal dari backend berdasarkan plantId ---
Future<void> _loadQuestionsFromBackend() async {
  if (widget.plantId.isEmpty) return; // pastikan plantId ada
  try {
    final data = await api.fetchQuestionsByPlant(
      int.tryParse(widget.plantId) ?? 0, // konversi String ke int
    );
    setState(() {
      questions = data;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal memuat soal: $e")),
    );
  }
}

  /// --- Fungsi add question hanya lokal, backend dinonaktifkan ---
  Future<void> _addQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      _showSnack("Pertanyaan belum diisi.");
      return;
    }

    if (questionType == "Multiple Choice" &&
        _optionControllers.any((c) => c.text.trim().isEmpty)) {
      _showSnack("Lengkapi semua opsi jawaban terlebih dahulu.");
      return;
    }

    final newQuestion = MCQuestion(
      id: questions.length + 1,
      plantId: int.tryParse(widget.plantId) ?? 0,
      question: _questionController.text.trim(),
      type: questionType,
      optionA: questionType == "Multiple Choice"
          ? _optionControllers[0].text.trim()
          : "True",
      optionB: questionType == "Multiple Choice"
          ? _optionControllers[1].text.trim()
          : "False",
      optionC: questionType == "Multiple Choice"
          ? _optionControllers[2].text.trim()
          : null,
      optionD: questionType == "Multiple Choice"
          ? _optionControllers[3].text.trim()
          : null,
      correctAnswer: questionType == "Multiple Choice"
          ? String.fromCharCode(65 + _correctIndex)
          : _trueFalseAnswer,
      isSelected: false,
    );

    // Tambahkan hanya ke list lokal
    setState(() {
      questions.add(newQuestion);
    });

    _showSnack("Soal berhasil ditambahkan (lokal).");
    _clearForm();
  }

  void _clearForm() {
    _questionController.clear();
    for (var c in _optionControllers) c.clear();
    _correctIndex = 0;
    _trueFalseAnswer = "True";
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _deleteSelected() {
    setState(() {
      questions.removeWhere((q) => q.isSelected);
    });
  }

  int get selectedCount => questions.where((q) => q.isSelected).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Manajemen Soal (${widget.plantId})"),
        backgroundColor: const Color(0xFF07840B),
        actions: [
          if (selectedCount > 0)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Jenis Soal: "),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: questionType,
                  items: const [
                    DropdownMenuItem(
                        value: "Multiple Choice", child: Text("Multiple Choice")),
                    DropdownMenuItem(
                        value: "True False", child: Text("True / False")),
                  ],
                  onChanged: (val) => setState(() => questionType = val!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuestionForm(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text("Tambah Soal"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07840B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text("Daftar Soal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (questions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Belum ada soal."),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: q.isSelected,
                        onChanged: (val) {
                          setState(() => q.isSelected = val ?? false);
                        },
                      ),
                      title: Text(q.question),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (q.optionA != null) Text("A. ${q.optionA}"),
                          if (q.optionB != null) Text("B. ${q.optionB}"),
                          if (q.optionC != null) Text("C. ${q.optionC}"),
                          if (q.optionD != null) Text("D. ${q.optionD}"),
                          const SizedBox(height: 4),
                          Text(
                            "Jawaban Benar: ${q.correctAnswer ?? '-'}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionForm() {
    if (questionType == "Multiple Choice") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _questionController,
            decoration: const InputDecoration(
              labelText: "Pertanyaan (Multiple Choice)",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            "Opsi Jawaban (pilih satu yang benar):",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Radio<int>(
                    value: i,
                    groupValue: _correctIndex,
                    onChanged: (val) => setState(() => _correctIndex = val ?? 0),
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
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _questionController,
            decoration: const InputDecoration(
              labelText: "Pernyataan True / False",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _trueFalseAnswer,
            items: ["True", "False"]
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) => setState(() => _trueFalseAnswer = val ?? "True"),
            decoration: const InputDecoration(
              labelText: "Jawaban Benar",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
  }
}
