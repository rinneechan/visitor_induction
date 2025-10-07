import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/models/plant_model.dart';
import 'package:she_vi/models/mc_question.dart';
import 'package:she_vi/services/api_service.dart';

class CmsInductionScreen extends StatefulWidget {
  final String? plantId;
  const CmsInductionScreen({super.key, this.plantId});

  @override
  State<CmsInductionScreen> createState() => _CmsInductionScreenState();
}

class _CmsInductionScreenState extends State<CmsInductionScreen> {
  final ApiService api = ApiService();

  List<Plant> plants = [];
  Plant? selectedPlant;
  List<MCQuestion> questions = [];
  bool isLoadingPlants = false;
  bool isLoadingQuestions = false;

  final List<Map<String, String>> materials = [
    {"title": "Prosedur K3 Dasar", "file": "k3_basic_safety.pptx"},
    {"title": "Panduan APD di Area Kerja", "file": "safety_equipment_guide.pptx"},
  ];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => isLoadingPlants = true);
    try {
      final fetchedPlants = await api.fetchPlantsCMS();
      setState(() {
        plants = fetchedPlants;
        if (widget.plantId != null && widget.plantId!.isNotEmpty) {
          selectedPlant = plants.firstWhere(
            (p) => p.id.toString() == widget.plantId,
            orElse: () =>
                plants.isNotEmpty ? plants.first : Plant(id: 0, code: '', name: '', isActive: true),
          );
          _loadQuestions();
        }
      });
    } finally {
      setState(() => isLoadingPlants = false);
    }
  }

  Future<void> _loadQuestions() async {
    if (selectedPlant == null) return;
    setState(() => isLoadingQuestions = true);
    try {
      final fetched = await api.fetchQuestionsByPlant(selectedPlant!.id);
      setState(() {
        questions = fetched;
      });
    } catch (_) {
      setState(() => questions = []);
    } finally {
      setState(() => isLoadingQuestions = false);
    }
  }

  void _onPlantChanged(Plant? newPlant) {
    if (newPlant == null) return;
    setState(() {
      selectedPlant = newPlant;
      questions = [];
    });
    _loadQuestions();
  }

  // ROUTE TAMBAH MATERI
  void _goToAddMaterial() {
    if (selectedPlant == null) return;
    // Kirim plantId sebagai string
    context.push('/cms/material/add', extra: selectedPlant!.id.toString());
  }

  // ROUTE TAMBAH SOAL
  void _goToCmsQuestionScreen() {
    if (selectedPlant == null) return;
    context.push('/cms/questions', extra: selectedPlant!.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("CMS Induction", style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoadingPlants
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown Plant
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pilih Plant:",
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      DropdownButton<Plant>(
                        value: selectedPlant,
                        hint: Text("Pilih Plant", style: GoogleFonts.hankenGrotesk()),
                        items: plants
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name, style: GoogleFonts.hankenGrotesk()),
                                ))
                            .toList(),
                        onChanged: _onPlantChanged,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // List Soal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Daftar Soal",
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                        onPressed: _goToCmsQuestionScreen,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text("Tambah Soal",
                            style: GoogleFonts.hankenGrotesk(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    flex: 2,
                    child: isLoadingQuestions
                        ? const Center(child: CircularProgressIndicator())
                        : questions.isEmpty
                            ? Center(
                                child: Text(
                                  "Belum ada soal untuk plant ini.",
                                  style: GoogleFonts.hankenGrotesk(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: questions.length,
                                itemBuilder: (context, index) {
                                  final q = questions[index];
                                  return GestureDetector(
                                    onTap: () => _showQuestionDetail(q),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              blurRadius: 5,
                                              offset: const Offset(0, 3))
                                        ],
                                      ),
                                      child: Text("${index + 1}. ${q.question}",
                                          style: GoogleFonts.hankenGrotesk(
                                              fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                  );
                                },
                              ),
                  ),

                  const SizedBox(height: 16),

                  // Materi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Daftar Materi",
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                        onPressed: _goToAddMaterial,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text("Tambah Materi",
                            style: GoogleFonts.hankenGrotesk(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final mat = materials[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.picture_as_pdf, color: Color(0xFF2E7D32)),
                            title: Text(mat["title"] ?? '',
                                style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600)),
                            subtitle: Text(mat["file"] ?? '',
                                style: GoogleFonts.hankenGrotesk()),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showQuestionDetail(MCQuestion question) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Detail Soal", style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.question, style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (question.isMultipleChoice) ...[
              if (question.optionA != null) Text("A. ${question.optionA}", style: GoogleFonts.hankenGrotesk()),
              if (question.optionB != null) Text("B. ${question.optionB}", style: GoogleFonts.hankenGrotesk()),
              if (question.optionC != null) Text("C. ${question.optionC}", style: GoogleFonts.hankenGrotesk()),
              if (question.optionD != null) Text("D. ${question.optionD}", style: GoogleFonts.hankenGrotesk()),
            ] else if (question.isTrueFalse) ...[
              Text("A. Benar", style: GoogleFonts.hankenGrotesk()),
              Text("B. Salah", style: GoogleFonts.hankenGrotesk()),
            ],
            const SizedBox(height: 8),
            Text("Jawaban Benar: ${question.correctAnswer ?? '-'}",
                style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: GoogleFonts.hankenGrotesk()),
          ),
        ],
      ),
    );
  }
}
