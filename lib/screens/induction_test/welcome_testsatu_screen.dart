import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'video_player_page.dart';
import 'web_pdf_viewer.dart';
// Pastikan impor PDF viewer sesuai platform Anda

class WelcomeTestSatuScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;

  const WelcomeTestSatuScreen({
    super.key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
  });

  @override
  _WelcomeTestSatuScreenState createState() => _WelcomeTestSatuScreenState();
}

class _WelcomeTestSatuScreenState extends State<WelcomeTestSatuScreen> {
  late Box box;
  String? username;
  String? visitorid;
  String? email;
  bool isDocumentRead = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    final token = box.get('token');

    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
    });

    if (token == null || token.isEmpty) {
      context.go('/choose-access');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildHeaderTitle(),
                      const SizedBox(height: 24),
                      _buildUserGreeting(),
                      const SizedBox(height: 24),
                      _buildCG(),
                      const SizedBox(height: 24),
                      _buildPlantInfo(),
                      const SizedBox(height: 24),
                      _buildInstructions(),
                      const SizedBox(height: 24),
                      _buildDownloadButton(),
                      const SizedBox(height: 24),
                      _buildConfirmationButton(),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF07840B))),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/logo-cg.svg',
              height: 30,
              placeholderBuilder: (context) =>
                  const CircularProgressIndicator(),
            ),
            const SizedBox(width: 8),
            const Text(
              'CEMINDO GEMILANG',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB0191F),
                fontFamily: 'Lato',
              ),
            ),
          ],
        ),
        Image.asset(
          'assets/images/logo-sedia.png',
          height: 35,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 35),
        ),
      ],
    );
  }

  Widget _buildHeaderTitle() {
    return Column(
      children: [
        const Divider(color: Colors.grey, thickness: 1),
        const SizedBox(height: 8),
        const Text(
          'VISITOR INDUCTIONS',
          style: TextStyle(
            color: Color(0xFF07840B),
            fontFamily: 'Hanken Grotesk',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.grey, thickness: 1),
      ],
    );
  }

  Widget _buildUserGreeting() {
    return Text(
      username != null ? 'Hello, $username' : 'Loading...',
      style: const TextStyle(
        color: Color(0xFF757575),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildCG() {
    return const Text(
      'WELCOME TO\nPT CEMINDO GEMILANG TBK',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF343434),
        fontFamily: 'Hanken Grotesk',
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildPlantInfo() {
    return Text(
      widget.plantName,
      style: const TextStyle(
        color: Color(0xFF757575),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildInstructions() {
    return const Text(
      'Before taking your access pass test, please download and read our safety materials to fully understand the safety rules at our plant sites.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF343434),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showDocument(context, widget.plantId),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF07840B)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Download Induction Material',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF07840B),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDocumentRead
            ? () {
                context.push(
                  '/welcome-test-intructions',
                  extra: {
                    'idrequest': widget.idrequest,
                    'plantId': widget.plantId,
                    'plantName': widget.plantName,
                  },
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDocumentRead ? const Color(0xFF07840B) : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'I have read and understood the safety rules of the plant sites.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDocumentRead ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  void _showDocument(BuildContext context, String byplant) async {
    if (isLoading) return;

    setState(() => isLoading = true);
    try {
      final response = await ApiService().materiByPlant(byplant);
      if (response.isEmpty) throw Exception('No document found');

      final documentUrl = response[0].linkData;
      final extension =
          documentUrl.split('.').last.split('?').first.toLowerCase();

      if (extension == 'mp4') {
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(
              videoUrl: documentUrl,
              onFinishedWatching: () => setState(() => isDocumentRead = true),
            ),
          ),
        );
      } else if (extension == 'pdf') {
        if (kIsWeb) {
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebPdfViewer(
                documentUrl: documentUrl,
                onFinishedReading: () => setState(() => isDocumentRead = true),
              ),
            ),
          );
        } else {
          // Handle PDF download for mobile
          // ... (kode download tetap sama)
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat dokumen: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
