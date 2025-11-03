import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/models/plant_model.dart';
import 'package:she_vi/models/mc_question.dart';
import 'package:she_vi/models/material_by_plant_cms.dart';
import 'package:she_vi/models/inductionMaterial.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';

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
  List<MaterialByPlantCMS> materials = [];

  bool isLoadingPlants = false;
  bool isLoadingQuestions = false;
  bool isLoadingMaterials = false;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  /// ✅ Ambil daftar plant dan tambahkan "All Plant" di atas
  Future<void> _loadPlants() async {
    setState(() => isLoadingPlants = true);
    try {
      final fetchedPlants = await api.fetchPlantsCMS();

      final allOption = Plant(
        id: 0,
        code: '',
        name: 'All Plant',
        isActive: true,
      );

      setState(() {
        plants = [allOption, ...fetchedPlants];
        if (widget.plantId != null && widget.plantId!.isNotEmpty) {
          selectedPlant = plants.firstWhere(
            (p) => p.id.toString() == widget.plantId,
            orElse: () => allOption,
          );
        } else {
          selectedPlant = allOption;
        }
      });

      // Saat pertama kali buka, langsung load All Plant
      await _loadQuestions();
    } catch (e) {
      debugPrint('❌ Gagal memuat plant: $e');
    } finally {
      setState(() => isLoadingPlants = false);
    }
  }

  /// ✅ Load “All Plant” materials dari API induction_material
  Future<void> _loadQuestions() async {
    setState(() => isLoadingQuestions = true);
    try {
      // Jika selectedPlant = "All Plant", panggil induction_material API
      if (selectedPlant != null && selectedPlant!.name == "All Plant") {
        final fetchedMaterials = await api.fetchInductionMaterials();

        setState(() {
          materials = fetchedMaterials
              .map(
                (e) => MaterialByPlantCMS(
                  id: e.idMateri,
                  materialName: e.namaMateri,
                  fileName: e.urlMateri,
                  folder: 'All Plant',
                  plantId: 0,
                ),
              )
              .toList();
          questions = []; // Kosongkan pertanyaan di All Plant
        });
      } else {
        // Jika bukan All Plant, load berdasarkan plant
        await _loadDataForPlant();
      }
    } catch (e) {
      debugPrint('❌ Gagal memuat data induction material: $e');
    } finally {
      setState(() => isLoadingQuestions = false);
    }
  }

  /// ✅ Load data pertanyaan dan materi berdasarkan plant tertentu
  Future<void> _loadDataForPlant() async {
    if (selectedPlant == null) return;
    setState(() {
      isLoadingQuestions = true;
      isLoadingMaterials = true;
    });

    try {
      final fetchedQuestions =
          await api.fetchQuestionsByPlant(selectedPlant!.id);
      final fetchedMaterials =
          await api.fetchMaterialsByPlant(selectedPlant!.id.toString());

      setState(() {
        questions = fetchedQuestions;
        materials = fetchedMaterials;
      });
    } catch (e) {
      debugPrint('❌ Error loading data per plant: $e');
      setState(() {
        questions = [];
        materials = [];
      });
    } finally {
      setState(() {
        isLoadingQuestions = false;
        isLoadingMaterials = false;
      });
    }
  }

  /// ✅ Aksi saat dropdown plant diganti
  void _onPlantChanged(Plant? newPlant) async {
    if (newPlant == null) return;
    setState(() {
      selectedPlant = newPlant;
      questions = [];
      materials = [];
    });

    await _loadQuestions(); // auto-refresh sesuai pilihan
  }

  /// Navigasi ke halaman tambah material
  Future<void> _goToAddMaterial() async {
    if (selectedPlant == null) return;

    final result = await context.push('/cms/material/add',
        extra: {'plantId': selectedPlant!.id.toString()});

    if (result == 'refresh') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Materi baru berhasil ditambahkan!',
            style: GoogleFonts.hankenGrotesk()),
        backgroundColor: Colors.green[700],
      ));
      _loadDataForPlant();
    }
  }

  void _goToCmsQuestionScreen() {
    if (selectedPlant == null) return;
    context.push('/cms/questions',
        extra: {'plantId': selectedPlant!.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(username: "Admin CMS"),
      appBar: AppBar(
        title: Text(
          "CMS Induction",
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoadingPlants
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =======================
                  // 🌱 Dropdown Plant
                  // =======================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pilih Plant:",
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Plant>(
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(12),
                              dropdownColor: Colors.white,
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: Colors.green[700]),
                              value: selectedPlant,
                              hint: Text(
                                "Pilih Plant",
                                style: GoogleFonts.hankenGrotesk(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              items: plants
                                  .map(
                                    (p) => DropdownMenuItem<Plant>(
                                      value: p,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Text(
                                          p.name,
                                          style: GoogleFonts.hankenGrotesk(
                                            fontSize: 16,
                                            color: Colors.green[900],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _onPlantChanged,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =======================
                  // 📘 Daftar Soal
                  // =======================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Daftar Soal",
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32)),
                        onPressed: _goToCmsQuestionScreen,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text("Tambah Soal",
                            style: GoogleFonts.hankenGrotesk(
                                color: Colors.white)),
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
                                  selectedPlant?.name == "All Plant"
                                      ? "Soal tidak tersedia di mode All Plant."
                                      : "Belum ada soal untuk plant ini.",
                                  style: GoogleFonts.hankenGrotesk(
                                      color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: questions.length,
                                itemBuilder: (context, index) {
                                  final q = questions[index];
                                  return GestureDetector(
                                    onTap: () => _showQuestionDetail(q),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.grey.withOpacity(0.2),
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          )
                                        ],
                                      ),
                                      child: Text("${index + 1}. ${q.question}",
                                          style: GoogleFonts.hankenGrotesk(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                  );
                                },
                              ),
                  ),

                  const SizedBox(height: 16),

                  // =======================
                  // 📂 Daftar Materi
                  // =======================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Daftar Materi",
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32)),
                        onPressed: _goToAddMaterial,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text("Tambah Materi",
                            style: GoogleFonts.hankenGrotesk(
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    flex: 1,
                    child: isLoadingMaterials
                        ? const Center(child: CircularProgressIndicator())
                        : materials.isEmpty
                            ? Center(
                                child: Text(
                                  "Belum ada materi untuk plant ini.",
                                  style: GoogleFonts.hankenGrotesk(
                                      color: Colors.grey),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadQuestions,
                                child: ListView.builder(
                                  itemCount: materials.length,
                                  itemBuilder: (context, index) {
                                    final mat = materials[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2))
                                        ],
                                      ),
                                      child: ListTile(
                                        leading: const Icon(
                                            Icons.picture_as_pdf,
                                            color: Color(0xFF2E7D32)),
                                        title: Text(
                                            mat.materialName ??
                                                'Nama materi tidak tersedia',
                                            style: GoogleFonts.hankenGrotesk(
                                                fontWeight: FontWeight.w600)),
                                        subtitle: Text(
                                            "Material ID: ${mat.id ?? '-'}",
                                            style: GoogleFonts.hankenGrotesk()),
                                      ),
                                    );
                                  },
                                ),
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
        title: Text("Detail Soal",
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question.question,
                  style: GoogleFonts.hankenGrotesk(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (question.isMultipleChoice) ...[
                if (question.optionA != null)
                  Text("A. ${question.optionA}",
                      style: GoogleFonts.hankenGrotesk()),
                if (question.optionB != null)
                  Text("B. ${question.optionB}",
                      style: GoogleFonts.hankenGrotesk()),
                if (question.optionC != null)
                  Text("C. ${question.optionC}",
                      style: GoogleFonts.hankenGrotesk()),
                if (question.optionD != null)
                  Text("D. ${question.optionD}",
                      style: GoogleFonts.hankenGrotesk()),
              ] else if (question.isTrueFalse) ...[
                Text("A. Benar", style: GoogleFonts.hankenGrotesk()),
                Text("B. Salah", style: GoogleFonts.hankenGrotesk()),
              ],
              const SizedBox(height: 8),
              Text("Jawaban Benar: ${question.correctAnswer ?? '-'}",
                  style: GoogleFonts.hankenGrotesk(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32))),
            ],
          ),
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
