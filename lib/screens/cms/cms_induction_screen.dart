import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';

class CmsInductionScreen extends StatelessWidget {
  const CmsInductionScreen({super.key});

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

            // Grid untuk Question
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
                  onTap: () => context.go('/cms/multiplechoice'),
                ),
                _cmsCard(
                  context,
                  title: "True or False",
                  icon: Icons.check_circle_outline,
                  onTap: () => context.go('/cms/truefalse'),
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

            // Card Material lebar penuh
            _cmsCard(
              context,
              title: "Content Material",
              icon: Icons.menu_book_outlined,
              onTap: () => context.go('/cms/material'),
              isFull: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable CMS Card dengan animasi ripple + scale
  Widget _cmsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isFull = false,
  }) {
    final card = TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0xFF07840B).withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 140,
            width: isFull ? double.infinity : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 42, color: const Color(0xFF07840B)),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
