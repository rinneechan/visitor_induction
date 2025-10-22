import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaterialDetailScreen extends StatefulWidget {
  final String kode; // dari route
  const MaterialDetailScreen({super.key, required this.kode});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  bool isEditing = false;
  late TextEditingController titleController;
  String selectedPlant = '';
  String fileName = '';
  IconData fileIcon = Icons.insert_drive_file;

  @override
  void initState() {
    super.initState();
    // TODO: fetch data dari kode (widget.kode) misal dari API/DB
    // Contoh dummy:
    titleController = TextEditingController(text: 'Judul Material ${widget.kode}');
    selectedPlant = 'Plant Bayah';
    fileName = 'example_file.pdf';
    fileIcon = Icons.picture_as_pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF07840B),
        elevation: 0,
        title: Text(
          isEditing ? "Edit Material" : "Material Detail",
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/cms/material'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            isEditing
                ? TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Material Title",
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    titleController.text,
                    style: const TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 20),

            // Plant
            isEditing
                ? DropdownButtonFormField<String>(
                    value: selectedPlant,
                    items: ["Plant Bayah", "Plant Ciwandan", "Plant Medan", "Plant Pontianak"]
                        .map((plant) => DropdownMenuItem(
                              value: plant,
                              child: Text(plant),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedPlant = value);
                    },
                    decoration: const InputDecoration(
                      labelText: "Select Plant",
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    "Plant: $selectedPlant",
                    style: const TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
            const SizedBox(height: 20),

            // File Preview
            Row(
              children: [
                Icon(fileIcon, size: 40, color: Colors.grey[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: () {
                      // TODO: implement ganti file
                      setState(() {
                        fileName = "new_file.pdf"; // contoh
                        fileIcon = Icons.picture_as_pdf;
                      });
                    },
                    child: const Text(
                      "Replace File",
                      style: TextStyle(color: Color(0xFF07840B)),
                    ),
                  ),
              ],
            ),
            const Spacer(),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isEditing ? const Color(0xFF056309) : const Color(0xFF07840B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        // TODO: Save ke DB
                        setState(() {
                          isEditing = false;
                        });
                      } else {
                        setState(() {
                          isEditing = true;
                        });
                      }
                    },
                    child: Text(
                      isEditing ? "Save Changes" : "Edit Material",
                      style: const TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (isEditing)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
