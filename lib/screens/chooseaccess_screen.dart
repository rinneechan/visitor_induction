import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class ChooseAccess extends StatefulWidget {
  const ChooseAccess({super.key});

  @override
  _ChooseAccessScreenState createState() => _ChooseAccessScreenState();
}

class _ChooseAccessScreenState extends State<ChooseAccess> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      context.go('/main-menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    double fontSize(double mobile, double tablet, double web) =>
        isMobile ? mobile : (isTablet ? tablet : web);

    double elementSize(double mobile, double tablet, double web) =>
        isMobile ? mobile : (isTablet ? tablet : web);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.shortestSide,
                height: screenHeight,
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/BackgroundSedia.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey),
                      ),
                    ),
                    // Content
                    Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: elementSize(16, 24, 32),
                              horizontal: elementSize(16, 24, 32),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Are you CG',
                                  style: TextStyle(
                                    fontSize: fontSize(40, 36, 40),
                                    color: Color.fromARGB(255, 7, 132, 11),
                                    fontFamily: 'Hanken Grotesk',
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Employee?',
                                  style: TextStyle(
                                    fontSize: fontSize(40, 36, 40),
                                    color: Color.fromARGB(255, 7, 132, 11),
                                    fontFamily: 'Hanken Grotesk',
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Select one option from the list below.',
                                  style: TextStyle(
                                    color: Color(0xFF757575),
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: fontSize(16, 16, 18),
                                    fontWeight: FontWeight.w400,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom Option Cards
                        buildBottomOptions(
                          fontSize: fontSize,
                          elementSize: elementSize,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildBottomOptions({
    required double Function(double, double, double) fontSize,
    required double Function(double, double, double) elementSize,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildOption(
              title: 'CG Employee',
              subtitle: 'Login with your Employee ID.',
              iconPath: 'assets/images/Right-Scroll.svg',
              onTap: () => context.go('/login'),
              fontSize: fontSize,
              elementSize: elementSize,
            ),
            SizedBox(height: 10),
            buildOption(
              title: 'External Visitor',
              subtitle: 'Provide with your details.',
              iconPath: 'assets/images/Right-Scroll.svg',
              onTap: () => context.go('/main-menu-ext'),
              fontSize: fontSize,
              elementSize: elementSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOption({
    required String title,
    required String subtitle,
    required String iconPath,
    required VoidCallback onTap,
    required double Function(double, double, double) fontSize,
    required double Function(double, double, double) elementSize,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: fontSize(18, 20, 22),
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF343434),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: fontSize(12, 14, 16),
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              SvgPicture.asset(
                iconPath,
                height: elementSize(30, 35, 40),
                width: elementSize(30, 35, 40),
                placeholderBuilder: (context) =>
                    CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
