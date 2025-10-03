import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';
import 'package:she_vi/models/plant_model.dart';
import 'package:she_vi/services/api_service.dart';

class CmsInductionScreen extends StatefulWidget {
  const CmsInductionScreen({super.key});

  @override
  State<CmsInductionScreen> createState() => _CmsInductionScreenState();
}

class _CmsInductionScreenState extends State<CmsInductionScreen> {
  Plant? selectedPlant; // ✅ ubah jadi Plant object, bukan String
  List<Plant> plants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  Future<void> _fetchPlants() async {
    try {
      final api = ApiService();
      final data = await api.fetchPlantsCMS();
      setState(() {
        plants = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetch plants: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07840B),
        elevation: 0,
        title: const Text(
          "CMS - Induction",
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔽 Dropdown Plant
            const Text(
              "Pilih Plant",
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Plant>(
                    value: selectedPlant,
                    hint: const Text("Pilih Plant"),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: plants
                        .map((plant) => DropdownMenuItem<Plant>(
                              value: plant,
                              child: Text(plant.plantName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPlant = value;
                      });
                    },
                  ),

            const SizedBox(height: 28),

            const Text(
              "Question",
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _cmsCard(
                  context,
                  title: "Multiple Choice",
                  icon: Icons.list_alt_outlined,
                  enabled: selectedPlant != null,
                  onTap: () {
                    if (selectedPlant != null) {
                      context.go('/cms/multiplechoice',
                          extra: {"plant": selectedPlant!.id});
                    }
                  },
                ),
                _cmsCard(
                  context,
                  title: "True or False",
                  icon: Icons.check_circle_outline,
                  enabled: selectedPlant != null,
                  onTap: () {
                    if (selectedPlant != null) {
                      context.go('/cms/truefalse',
                          extra: {"plant": selectedPlant!.id});
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              "Material",
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _cmsCard(
              context,
              title: "Content Material",
              icon: Icons.menu_book_outlined,
              enabled: selectedPlant != null,
              onTap: () {
                if (selectedPlant != null) {
                  context.go('/cms/material',
                      extra: {"plant": selectedPlant!.id});
                }
              },
              isFull: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cmsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isFull = false,
    bool enabled = true,
  }) {
    final card = Material(
      color: enabled ? Colors.white : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(20),
      elevation: enabled ? 2 : 0,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        splashColor: enabled
            ? const Color(0xFF07840B).withOpacity(0.2)
            : Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 140,
          width: isFull ? double.infinity : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color: enabled ? const Color(0xFF07840B) : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: enabled ? const Color(0xFF333333) : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    return isFull
        ? Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: card,
          )
        : card;
  }
}
