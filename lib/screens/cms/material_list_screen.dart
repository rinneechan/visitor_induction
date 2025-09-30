import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaterialItem {
  final String kode;
  final String title;
  final String description;
  final String uploadedAt;
  final String fileName;
  bool isSelected;

  MaterialItem({
    required this.kode,
    required this.title,
    required this.description,
    required this.uploadedAt,
    required this.fileName,
    this.isSelected = false,
  });
}

class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({Key? key}) : super(key: key);

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  String selectedTab = "All";

// Ubah di list dummy materials
List<MaterialItem> materials = [
  MaterialItem(
    kode: "MAT-001",
    title: "Safety Helmet Usage",
    description: "Panduan penggunaan helm keselamatan di area kerja.",
    uploadedAt: "2025-09-20",
    fileName: "safety_helmet.pdf",
  ),
  MaterialItem(
    kode: "MAT-002",
    title: "Fire Extinguisher Manual",
    description: "Langkah-langkah penggunaan APAR dengan benar.",
    uploadedAt: "2025-09-22",
    fileName: "fire_extinguisher_manual.ppt", // ubah dari docx menjadi ppt
  ),
  MaterialItem(
    kode: "MAT-003",
    title: "Emergency Evacuation Video",
    description: "Video prosedur evakuasi darurat di gedung.",
    uploadedAt: "2025-09-25",
    fileName: "evacuation_guide.mp4",
  ),
];

  List<MaterialItem> get filteredMaterials {
    if (selectedTab == "All") return materials;
    return materials
        .where((m) =>
            m.fileName.toLowerCase().endsWith(selectedTab.toLowerCase()))
        .toList();
  }

  int get selectedCount => materials.where((m) => m.isSelected).length;

  void toggleSelectAll(bool select) {
    setState(() {
      for (var m in filteredMaterials) {
        m.isSelected = select;
      }
    });
  }

// Ubah fungsi getFileIcon untuk docx -> ppt icon
IconData getFileIcon(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith(".pdf")) return Icons.picture_as_pdf;
  if (lower.endsWith(".ppt") || lower.endsWith(".pptx")) return Icons.slideshow; // ubah docx ke ppt
  if (lower.endsWith(".mp4") || lower.endsWith(".avi") || lower.endsWith(".mov")) {
    return Icons.videocam;
  }
  if (lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png")) {
    return Icons.image;
  }
  return Icons.insert_drive_file;
}

// Ubah warna icon juga untuk ppt
Color getFileIconColor(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith(".pdf")) return Colors.red;
  if (lower.endsWith(".ppt") || lower.endsWith(".pptx")) return Colors.orange; // docx -> ppt
  if (lower.endsWith(".mp4") || lower.endsWith(".avi") || lower.endsWith(".mov")) {
    return Colors.orangeAccent;
  }
  if (lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png")) {
    return Colors.green;
  }
  return Colors.grey;
}

  @override
  Widget build(BuildContext context) {
    final pdfCount =
        materials.where((m) => m.fileName.toLowerCase().endsWith(".pdf")).length;
    final docxCount = materials
        .where((m) => m.fileName.toLowerCase().endsWith(".docx"))
        .length;
    final mp4Count =
        materials.where((m) => m.fileName.toLowerCase().endsWith(".mp4")).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CMS - Materials",
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
                _buildTab("All", materials.length),
                const SizedBox(width: 8),
                _buildTab("pdf", pdfCount),
                const SizedBox(width: 8),
                _buildTab("docx", docxCount),
                const SizedBox(width: 8),
                _buildTab("mp4", mp4Count),
              ],
            ),
          ),

          const Divider(height: 1),

          // List Materials
          Expanded(
            child: ListView.builder(
              itemCount: filteredMaterials.length,
              itemBuilder: (context, index) {
                final mat = filteredMaterials[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.grey, width: 0.3),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(
                      getFileIcon(mat.fileName),
                      color: getFileIconColor(mat.fileName),
                      size: 36,
                    ),
                    title: Text(
                      mat.title,
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
                          mat.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "File: ${mat.fileName}",
                          style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Uploaded: ${mat.uploadedAt}",
                          style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Checkbox(
                      activeColor: const Color(0xFF07840B),
                      value: mat.isSelected,
                      onChanged: (val) {
                        setState(() {
                          mat.isSelected = val ?? false;
                        });
                      },
                    ),
                    onTap: () {
                      context.go('/cms/material/${mat.kode}');
                    },
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
                        materials.removeWhere((m) => m.isSelected);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => toggleSelectAll(false),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.grey[300]),
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
                          return Colors.grey[700]!;
                        }
                        return Colors.grey[400]!;
                      }),
                      shape: WidgetStateProperty.all(const CircleBorder()),
                      padding:
                          WidgetStateProperty.all(const EdgeInsets.all(14)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  // Add Material
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/cms/material/add');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Material",
                        style: TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.hovered)) {
                            return const Color(0xFF056309);
                          }
                          return const Color(0xFF07840B);
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
                        shadowColor:
                            WidgetStateProperty.all(Colors.green.shade700),
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
