import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:she_vi/services/api_service_external.dart';
import 'package:universal_html/html.dart' as html;

// Viewer Pages
import 'video_player_page.dart';
import 'web_pdf_viewer_external.dart';
import 'mobile_pdf_viewer_external.dart';

class WelcomeTestSatuExternalScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;
  final String urlakses;

  const WelcomeTestSatuExternalScreen({
    super.key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
    required this.urlakses,
  });

  @override
  State<WelcomeTestSatuExternalScreen> createState() =>
      _WelcomeTestSatuExternalScreenState();
}

class _WelcomeTestSatuExternalScreenState
    extends State<WelcomeTestSatuExternalScreen> {
  String username = "";
  bool isDocumentRead = false;
  bool isLoading = false;
  bool isFetchingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndSetUsername();
  }

  // 🔹 Ambil profil dari API
  Future<void> _fetchProfileAndSetUsername() async {
    try {
      final request = await ApiServiceExternal.fetchInductionRequestByIdExternal(widget.idrequest);

      setState(() {
        // Ambil nama dari profil, fallback ke data[0].fullName
        username = request?.profil?.fullName ??
            (request != null && request.data.isNotEmpty
                ? request.data[0].fullName
                : "Guest");
        isFetchingProfile = false;
      });

      debugPrint("📌 USERNAME FETCHED: $username");
    } catch (e) {
      debugPrint("❌ Failed to fetch profile: $e");
      setState(() {
        username = "Guest";
        isFetchingProfile = false;
      });
    }
  }

  // -----------------------------------------
  // DOWNLOAD HANDLERS
  // -----------------------------------------
  Future<String> _downloadFile(String url, String filename) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');

      final res = await Dio().get(url,
          options: Options(responseType: ResponseType.bytes));

      await file.writeAsBytes(res.data);
      return file.path;
    } catch (e) {
      throw Exception("Download gagal: $e");
    }
  }

  Future<Uint8List> _downloadPdfForWeb(String url) async {
    try {
      final response =
          await html.HttpRequest.request(url, responseType: 'arraybuffer');

      if (response.response is ByteBuffer) {
        return (response.response as ByteBuffer).asUint8List();
      }

      throw Exception("Response tidak valid");
    } catch (e) {
      throw Exception("PDF Web Download Error: $e");
    }
  }

  // -----------------------------------------
  // PAGE BUILD
  // -----------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildMainContent(),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF07840B)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
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
    );
  }

  // -----------------------------------------
  // UI SECTIONS
  // -----------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset('assets/images/logo-cg.svg', height: 30),
            const SizedBox(width: 8),
            const Text(
              'CEMINDO GEMILANG',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB0191F),
              ),
            ),
          ],
        ),
        Image.asset('assets/images/logo-sedia.png', height: 35),
      ],
    );
  }

  Widget _buildHeaderTitle() {
    return Column(
      children: const [
        Divider(color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'VISITOR INDUCTIONS - EXTERNAL',
          style: TextStyle(
            color: Color(0xFF07840B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Divider(color: Colors.grey),
      ],
    );
  }

  Widget _buildUserGreeting() {
    if (isFetchingProfile) {
      return const Text(
        "Loading...",
        style: TextStyle(color: Color(0xFF757575), fontSize: 16),
      );
    }

    return Text(
      username.isEmpty ? "Hello, Guest" : "Hello, $username",
      style: const TextStyle(
        color: Color(0xFF757575),
        fontSize: 16,
      ),
    );
  }

  Widget _buildCG() {
    return const Text(
      'WELCOME TO\nPT CEMINDO GEMILANG TBK',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF343434),
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildPlantInfo() {
    return Text(
      widget.plantName.isEmpty ? "-" : widget.plantName,
      style: const TextStyle(color: Color(0xFF757575), fontSize: 16),
    );
  }

  Widget _buildInstructions() {
    return const Text(
      'Before taking your access pass test, please download and read our safety materials for external visitors.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF343434),
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showDocument(widget.plantId),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF07840B)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'Download Induction Material',
          style: TextStyle(
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
              // Navigasi ke Welcome Test Dua
              context.go(
                '/external/welcome-test-dua',
                extra: {
                  'idrequest': widget.idrequest,
                  'plantId': widget.plantId,
                  'plantName': widget.plantName,
                  "urlakses": widget.urlakses,
                },
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDocumentRead ? const Color(0xFF07840B) : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        'I have read and understood the safety rules.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isDocumentRead ? Colors.white : Colors.black54,
        ),
      ),
    ),
  );
}


  // -----------------------------------------
  // SHOW DOCUMENT HANDLER
  // -----------------------------------------
  Future<void> _showDocument(String plantId) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final material =
          await ApiServiceExternal().materiExternalByPlant(plantId);

      if (material == null) {
        throw Exception("Material tidak ditemukan");
      }

      final url = material.linkData;
      final ext = url.split('.').last.split('?').first.toLowerCase();

      if (ext == "mp4") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerPage(
              videoUrl: url,
              onFinishedWatching: () {
                setState(() => isDocumentRead = true);
              },
            ),
          ),
        );
      } else if (ext == "pdf") {
        if (kIsWeb) {
          final bytes = await _downloadPdfForWeb(url);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebPdfViewerExternal(
                pdfBytes: bytes,
                onFinishedReading: () {
                  setState(() => isDocumentRead = true);
                },
              ),
            ),
          );
        } else {
          final file = await _downloadFile(
              url, "material_${DateTime.now().millisecondsSinceEpoch}.pdf");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MobilePdfViewerExternal(
                localPath: file,
                onFinishedReading: () {
                  setState(() => isDocumentRead = true);
                },
              ),
            ),
          );
        }
      } else {
        throw Exception("Format tidak didukung: $ext");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memuat material: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }
}
