import 'package:flutter/material.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';
import 'package:she_vi/models/InductionRequestProgressExternal.dart';
import 'package:she_vi/services/api_service_external.dart';

class MenuExsternalScreen extends StatefulWidget {
  final String idrequest;

  const MenuExsternalScreen({super.key, required this.idrequest});

  @override
  State<MenuExsternalScreen> createState() => _MenuExsternalScreenState();
}

class _MenuExsternalScreenState extends State<MenuExsternalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  String? _errorMessage;

  // Data dari API
  List<InductionRequestProgressExternal> progressList = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final result = await ApiServiceExternal
          .fetchInductionProgressrequestExternal(widget.idrequest);

      setState(() {
        progressList = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data ($e)";
        _isLoading = false;
      });
    }
  }

  // ----------------------------------------------------------------------

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
                  child: _isLoading
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ))
                      : _errorMessage != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Column(
                              children: progressList.map((item) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.plant,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15)),
                                            Text(item.department,
                                                style: const TextStyle(
                                                    color: Colors.grey)),
                                            Text(item.dateRange,
                                                style: const TextStyle(
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.status,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _statusColor(item.status),
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
                // TRAINING MODULE SECTION (dummy tetap)
                // ------------------------------------------------------
                _buildSectionCard(
                  title: "SHE Training Module",
                  icon: Icons.menu_book_outlined,
                  child: Column(
                    children: [
                      "Plant Visitor Induction",
                      "Safety Procedures Overview",
                      "Emergency Response Plan",
                      "Basic Industrial Safety"
                    ].map((mat) {
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
                                  fontWeight: FontWeight.w500,
                                ),
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

  // Warna status
  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case "on-review":
        return const Color(0xFFFF9800);
      case "induction test":
        return const Color(0xFF1E88E5);
      case "active":
        return const Color(0xFF2E7D32);
      default:
        return Colors.black87;
    }
  }

  // ------------------------------------------------------
  // SECTION CARD
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
