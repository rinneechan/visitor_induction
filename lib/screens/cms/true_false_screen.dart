import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Question {
  final String kode;
  final String status; // "Active" atau "Draft"
  final String statement;
  final String createdAt;
  bool isSelected;

  Question({
    required this.kode,
    required this.status,
    required this.statement,
    required this.createdAt,
    this.isSelected = false,
  });
}

class TrueFalseScreen extends StatefulWidget {
  const TrueFalseScreen({Key? key}) : super(key: key);

  @override
  State<TrueFalseScreen> createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  String selectedTab = "All";

  // Dummy data
  List<Question> questions = [
    Question(
      kode: "TF-001",
      status: "Active",
      statement: "Helm keselamatan harus dipakai saat masuk area proyek.",
      createdAt: "2025-09-20",
    ),
    Question(
      kode: "TF-002",
      status: "Draft",
      statement: "Masker tidak diperlukan saat bekerja di area berdebu.",
      createdAt: "2025-09-21",
    ),
    Question(
      kode: "TF-003",
      status: "Active",
      statement: "Alat pemadam kebakaran dapat digunakan oleh siapa saja.",
      createdAt: "2025-09-22",
    ),
  ];

  List<Question> get filteredQuestions {
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
        title: const Text(
          "CMS - True or False",
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF07840B),
        elevation: 0,
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
                    child: const Text(
                      "Deselect All",
                      style: TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF07840B),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List Questions
          Expanded(
            child: ListView.builder(
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final q = filteredQuestions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.grey, width: 0.3),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Checkbox(
                      activeColor: const Color(0xFF07840B),
                      value: q.isSelected,
                      onChanged: (val) {
                        setState(() {
                          q.isSelected = val ?? false;
                        });
                      },
                    ),
                    title: Text(
                      q.kode,
                      style: const TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.statement,
                          style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Created: ${q.createdAt}",
                          style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      q.status,
                      style: TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: q.status == "Active"
                            ? const Color(0xFF07840B)
                            : Colors.orange,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Bar
      bottomNavigationBar: selectedCount > 0
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        questions.removeWhere((q) => q.isSelected);
                      });
                    },
                  ),
                  const SizedBox(width: 8),

                  // Clear Selection
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => toggleSelectAll(false),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.grey[300]),
                        overlayColor:
                            WidgetStateProperty.all(Colors.grey[700]),
                        foregroundColor:
                            WidgetStateProperty.all(Colors.black87),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                      ),
                      child: const Text("Clear Selection"),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Move Draft
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Move Draft action
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(const Color(0xFF07840B)),
                        overlayColor:
                            WidgetStateProperty.all(const Color(0xFF056309)),
                        foregroundColor:
                            WidgetStateProperty.all(Colors.white),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                        elevation: WidgetStateProperty.all(3),
                        shadowColor: WidgetStateProperty.all(Colors.green),
                      ),
                      child: const Text("Move Draft"),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back button
                  ElevatedButton(
                    onPressed: () {
                      context.go('/cms');
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.grey[700]!; // hover
                        }
                        return Colors.grey[400]!; // default
                      }),
                      shape: WidgetStateProperty.all(const CircleBorder()),
                      padding:
                          WidgetStateProperty.all(const EdgeInsets.all(14)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),

                  // Add Question
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/cms/truefalse/add');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Question",
                        style: TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.hovered)) {
                            return const Color(0xFF056309); // hover
                          }
                          return const Color(0xFF07840B); // default
                        }),
                        foregroundColor:
                            WidgetStateProperty.all(Colors.white),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )),
                        elevation: WidgetStateProperty.all(3),
                        shadowColor: WidgetStateProperty.all(Colors.green),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF000000) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
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
