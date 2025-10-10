import 'package:flutter/material.dart';
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

  Future<void> _loadQuestionsFromBackend() async {
    if (widget.plantId.isEmpty) return;
    try {
      final data = await api.fetchQuestionsByPlant(
        int.tryParse(widget.plantId) ?? 0,
      );
      setState(() => questions = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat soal: $e")),
      );
    }
  }

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

    setState(() => questions.add(newQuestion));
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
        title: const Text(
          "Add New Question",
          style: TextStyle(fontFamily: "HankenGrotesk"),
        ),
        backgroundColor: const Color(0xFF07840B),
        centerTitle: true,
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
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildQuestionForm(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: 24),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar Soal",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "HankenGrotesk",
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildQuestionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF07840B),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Form Tambah Soal",
                    style: TextStyle(
                      fontFamily: "HankenGrotesk",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Isi form di bawah untuk menambahkan pertanyaan baru.",
                    style: TextStyle(
                      fontFamily: "HankenGrotesk",
                      color: Colors.grey,
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

  Widget _buildQuestionForm() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Jenis Soal",
              style: TextStyle(
                fontFamily: "HankenGrotesk",
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: questionType,
              items: const [
                DropdownMenuItem(
                    value: "Multiple Choice", child: Text("Multiple Choice")),
                DropdownMenuItem(
                    value: "True False", child: Text("True / False")),
              ],
              onChanged: (val) => setState(() => questionType = val!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (questionType == "Multiple Choice")
              _buildMultipleChoiceFields()
            else
              _buildTrueFalseFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pertanyaan",
          style: TextStyle(fontFamily: "HankenGrotesk"),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _questionController,
          decoration: const InputDecoration(
            labelText: "Masukkan pertanyaan",
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const Text(
          "Opsi Jawaban (pilih satu yang benar):",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: "HankenGrotesk",
          ),
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
  }

  Widget _buildTrueFalseFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pernyataan",
          style: TextStyle(fontFamily: "HankenGrotesk"),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _questionController,
          decoration: const InputDecoration(
            labelText: "Masukkan pernyataan True / False",
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah Soal",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "HankenGrotesk",
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF07840B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildQuestionList() {
    if (questions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Belum ada soal."),
      );
    }

    return ListView.builder(
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
              onChanged: (val) => setState(() => q.isSelected = val ?? false),
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
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
