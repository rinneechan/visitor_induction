import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/models/tf_question.dart';

class TrueFalseScreen extends StatefulWidget {
  final String plantId;
  const TrueFalseScreen({Key? key, required this.plantId}) : super(key: key);

  @override
  State<TrueFalseScreen> createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  String selectedTab = "All";
  List<TFQuestion> questions = [];

  @override
  void initState() {
    super.initState();

    if (widget.plantId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/cms');
      });
    } else {
      // Dummy data sementara (bisa diganti API call)
      questions = List.generate(
        6,
        (index) => TFQuestion(
          kode: "TFQ-${index + 1}",
          statement: "Contoh pertanyaan True/False nomor ${index + 1}",
          createdAt: DateTime.now().toString().split(' ')[0],
          isSelected: false,
          status: index % 2 == 0 ? "Active" : "Draft",
        ),
      );
    }
  }

  List<TFQuestion> get filteredQuestions {
    if (selectedTab == "All") return questions;
    return questions.where((q) => q.status == selectedTab).toList();
  }

  int get selectedCount => questions.where((q) => q.isSelected).length;

  void toggleSelectAll(bool select) {
    setState(() {
      for (var q in filteredQuestions) {
        q.isSelected = select;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = questions.where((q) => q.status == "Active").length;
    final draftCount = questions.where((q) => q.status == "Draft").length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF07840B),
        elevation: 0,
        title: Text(
          "True/False Questions",
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ==== FILTER TABS ====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _buildTab("All", questions.length),
                const SizedBox(width: 8),
                _buildTab("Active", activeCount),
                const SizedBox(width: 8),
                _buildTab("Draft", draftCount),
                const Spacer(),
                if (selectedCount > 0)
                  GestureDetector(
                    onTap: () => toggleSelectAll(false),
                    child: const Text(
                      "Deselect All",
                      style: TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        color: Color(0xFF07840B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // ==== LIST ====
          Expanded(
            child: ListView.builder(
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final q = filteredQuestions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                  child: ListTile(
                    leading: Checkbox(
                      value: q.isSelected,
                      activeColor: const Color(0xFF07840B),
                      onChanged: (val) {
                        setState(() => q.isSelected = val ?? false);
                      },
                    ),
                    title: Text(
                      q.statement,
                      style: const TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      "Kode: ${q.kode} • ${q.createdAt}",
                      style: const TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: q.status == "Active"
                            ? Colors.green.shade100
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q.status,
                        style: TextStyle(
                          color: q.status == "Active"
                              ? Colors.green.shade800
                              : Colors.grey.shade700,
                          fontFamily: 'Hanken Grotesk',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() => q.isSelected = !q.isSelected);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ==== BOTTOM BAR ====
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/cms/$widget.plantId'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tambah pertanyaan baru"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // TODO: navigasi ke form tambah question
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  "Add Question",
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07840B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    final isActive = selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF07840B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF07840B) : Colors.grey.shade400,
            width: 1.2,
          ),
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
