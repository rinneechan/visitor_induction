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
      // Dummy data untuk True/False
      questions = List.generate(
        5,
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
      appBar: AppBar(
        title: Text("CMS - True/False (${widget.plantId})"),
        backgroundColor: const Color(0xFF07840B),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    child: const Text("Deselect All", style: TextStyle(color: Color(0xFF07840B))),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List pertanyaan
          Expanded(
            child: ListView.builder(
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final q = filteredQuestions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Checkbox(
                      value: q.isSelected,
                      onChanged: (val) {
                        setState(() => q.isSelected = val ?? false);
                      },
                    ),
                    title: Text(q.kode),
                    subtitle: Text(q.statement),
                    trailing: Text(q.status),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    final isActive = selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(color: isActive ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
