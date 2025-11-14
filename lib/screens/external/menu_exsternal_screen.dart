import 'package:flutter/material.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';

class MenuExsternalScreen extends StatefulWidget {
  final String idrequest;

  const MenuExsternalScreen({super.key, required this.idrequest});

  @override
  State<MenuExsternalScreen> createState() => _MenuExsternalScreenState();
}

class _MenuExsternalScreenState extends State<MenuExsternalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ------------------------------
  // DUMMY DATA (sementara)
  // ------------------------------
  final List<Map<String, dynamic>> dummyProgress = [
    {
      "plant": "BAYAH PLANT",
      "department": "Geologist",
      "date": "2025-11-12 - 1-3 Month",
      "status": "On-Review",
      "color": Color(0xFFFF9800),
    },
    {
      "plant": "CIWANDAN PLANT",
      "department": "IT System",
      "date": "2025-11-12 - 1-3 Month",
      "status": "Induction Test",
      "color": Color(0xFF1E88E5),
    },
    {
      "plant": "BAYAH PLANT",
      "department": "Packing and Dispatch",
      "date": "2025-10-15 - < 1 Month",
      "status": "Active",
      "color": Color(0xFF2E7D32),
    },
  ];

  final List<String> dummyMaterials = [
    "Plant Visitor Induction",
    "Safety Procedures Overview",
    "Emergency Response Plan",
    "Basic Industrial Safety"
  ];

  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF7F7F9),

      // ------------------------------------------------------
      // HEADER sesuai referensi
      // ------------------------------------------------------
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(56),
  child: Container(
    color: Colors.white,
    child: SafeArea(
      bottom: false, // supaya tidak ada space tambahan
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
              padding: EdgeInsets.zero, // hilangkan padding default IconButton
              constraints: const BoxConstraints(), // hilangkan constraints default supaya rapat
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

            const SizedBox(width: 32),

            const Text(
              "Visitor Induction",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),


      // ------------------------------------------------------
      // CONTENT
      // ------------------------------------------------------
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // ON PROGRESS SECTION
                // ------------------------------------------------------
                _buildSectionCard(
                  title: "On Progress",
                  icon: Icons.history,
                  child: Column(
                    children: dummyProgress.map((item) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item["plant"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                  Text(item["department"],
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  Text(item["date"],
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item["status"],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: item["color"],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // ------------------------------------------------------
                // TRAINING MODULE SECTION
                // ------------------------------------------------------
                _buildSectionCard(
                  title: "SHE Training Module",
                  icon: Icons.menu_book_outlined,
                  child: Column(
                    children: dummyMaterials.map((mat) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                mat,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              "Download",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF07840B),
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // SECTION CARD BUILDER (serupa referensi)
  // ------------------------------------------------------
 Widget _buildSectionCard({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Card(
    elevation: 0,
    color: Colors.white,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}
}
