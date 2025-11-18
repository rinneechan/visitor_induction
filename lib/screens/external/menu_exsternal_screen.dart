import 'package:flutter/material.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';
import 'package:she_vi/models/InductionRequestProgressExternal.dart';
import 'package:she_vi/services/api_service_external.dart';
import 'package:go_router/go_router.dart'; // Tambahkan import go_router

class MenuExternalScreen extends StatefulWidget {
  final String idrequest; // Ini mungkin digunakan untuk fetching, bukan untuk ID item

  const MenuExternalScreen({super.key, required this.idrequest});

  @override
  State<MenuExternalScreen> createState() => _MenuExternalScreenState();
}

class _MenuExternalScreenState extends State<MenuExternalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoadingProgress = true;
  String? _errorMessageProgress;
  // Tidak perlu _isLoadingModules dan _errorMessageModules jika data dummy
  List<String> trainingModules = [
    "Plant Visitor Induction",
    "Safety Procedures Overview",
    "Emergency Response Plan",
    "Basic Industrial Safety"
  ];

  List<InductionRequestProgressExternal> progressList = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoadingProgress = true;
      _errorMessageProgress = null;
    });

    try {
      final result = await ApiServiceExternal.fetchInductionProgressrequestExternal(widget.idrequest);
      setState(() {
        progressList = result;
        _isLoadingProgress = false;
      });
    } catch (e) {
      setState(() {
        _errorMessageProgress = "Gagal memuat data progress: $e";
        _isLoadingProgress = false;
      });
    }
  }

  // Warna berdasarkan status teks (misalnya "On-Review", "Induction Test")
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "on-review":
        return const Color(0xFFD18410);
      case "induction test": // Sesuaikan dengan teks status sebenarnya
        return const Color(0xFF1357BD);
      case "active":
        return const Color(0xFF07840B);
      case "completed": // Atau "selesai", sesuaikan
      case "expired":   // Atau status lainnya
        return const Color(0xFF757575);
      default:
        return Colors.black87;
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? headerAction,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (headerAction != null) headerAction,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(InductionRequestProgressExternal item) {
    return InkWell( // Bungkus dengan InkWell
      onTap: () {
        // Karena tidak ada statusid, cek berdasarkan teks status
        // Sesuaikan "Induction Test" dengan teks status sebenarnya dari API
        // if (item.status.toLowerCase() == "induction test" || item.status.toLowerCase() == "active") {
        //   // Gunakan properti 'id' dari model external
        //   context.push('/exsternal/detail-info?id=${item.id}');
        // }
        if (item.status.toLowerCase() == "induction test" ||
            item.status.toLowerCase() == "active") {
          context.push('/exsternal/detail-info?id=${item.id}&idrequest=${widget.idrequest}');
        }

      },
      child: Container(
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
                  Text(
                    item.plant,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    item.department,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    item.dateRange, // Gunakan getter dari model
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.status,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _getStatusColor(item.status), // Gunakan status teks untuk warna
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingModuleItem(String module) {
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
              module,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text(
            "Download",
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF07840B)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 32),
                  const Text(
                    "Visitor Induction",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ON PROGRESS SECTION
                _buildSectionCard(
                  title: "On Progress",
                  icon: Icons.history,
                  child: _isLoadingProgress
                      ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      : _errorMessageProgress != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _errorMessageProgress!,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: _loadProgress,
                                      child: const Text("Retry"),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: progressList.map((item) => _buildProgressItem(item)).toList(),
                            ),
                ),
                const SizedBox(height: 24),
                // TRAINING MODULE SECTION
                // _buildSectionCard(
                //   title: "SHE Training Module",
                //   icon: Icons.menu_book_outlined,
                //   child: Column(
                //     children: trainingModules.map((module) => _buildTrainingModuleItem(module)).toList(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}