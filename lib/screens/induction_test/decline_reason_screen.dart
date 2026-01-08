import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class TestComplatedScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;

  const TestComplatedScreen({
    super.key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
  });

  @override
  _TestComplatedScreenState createState() => _TestComplatedScreenState();
}

class _TestComplatedScreenState extends State<TestComplatedScreen> {
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
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token');

      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double bodyWidth = MediaQuery.of(context).size.width * 0.5; // 90% dari lebar layar
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        //appBar: _buildAppBar(bodyWidth),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double bodyWidth) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight), // Tinggi AppBar
      child: AppBar(
        backgroundColor: Colors.white, // Warna latar AppBar
        elevation: 0, // Menghapus bayangan pada AppBar
        centerTitle: false, // Menyelaraskan elemen ke sisi kiri dan kanan
        titleSpacing: 0, // Mengatur jarak awal judul
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo di sisi kiri
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // Jarak dari kiri
                  child: SvgPicture.asset(
                    'assets/images/logo-cg.svg',
                    height: 35.0,
                    placeholderBuilder: (context) =>
                        CircularProgressIndicator(), // Placeholder jika logo belum dimuat
                  ),
                ),
                const SizedBox(width: 8.0), // Jarak antara logo dan teks
                Text(
                  'CEMINDO GEMILANG',
                  style: const TextStyle(
                    fontSize: 11.429,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB0191F),
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
            // Logo di sisi kanan
            Padding(
              padding: const EdgeInsets.only(right: 8.0), // Jarak dari kanan
              child: Image.asset(
                'assets/images/logo-sedia.png',
                height: 40.0,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.shortestSide,
        //width: MediaQuery.of(context).size.width, // Memastikan lebar sesuai layar
        height: MediaQuery.of(context).size.height, // Memastikan tinggi sesuai layar
        child: Stack(
          children: [
            // Background container dengan warna tertentu
            // Container(color: Color(0xFFF0F0F0)),
            Container(color: Colors.white),

            // Card utama yang berada di atas Stack
            Positioned(
              top: 90, // Jarak dari atas, sesuaikan dengan kebutuhan
              left: 0,
              right: 0,
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildUserGreeting(),
                      const SizedBox(height: 24),
                      _buildCG(),
                      const SizedBox(height: 24),
                      _buildPlantInfo(),
                      const SizedBox(height: 24),
                      _buildInstructions(),
                      const SizedBox(height: 24),
                      // _buildDownloadButton(),
                      // const SizedBox(height: 24),
                      // _buildConfirmationButton(),
                    ],
                  ),
                ),
              ),
            ),

            // Menampilkan loading spinner jika isLoading bernilai true
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }


  // Header content
  Widget _buildHeader() {
    return Column(
      children: [
        //Divider(color: Colors.grey, thickness: 1.0),
        const SizedBox(height: 8),
        Text(
          'CONGRATULATIONS!',
          style: const TextStyle(
            color: Color(0xFF07840B),
            fontFamily: 'Hanken Grotesk',
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You have finished the induction Test',
          style: const TextStyle(
            color: Color(0xFF757575),
            fontFamily: 'Hanken Grotesk',
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        //Divider(color: Colors.grey, thickness: 1.0),
      ],
    );
  }

  // User greeting
  Widget _buildUserGreeting() {
    return username == null
        ? const CircularProgressIndicator()
        : Text(
      'Hello, $username',
      style: const TextStyle(
        color: Color(0xFF757575),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // CG welcome message
  Widget _buildCG() {
    return Text(
      'WELCOME TO\nPT CEMINDO GEMILANG TBK',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF343434),
        fontFamily: 'Hanken Grotesk',
        fontSize: 20.0,
        fontWeight: FontWeight.w900,
        height: 1.0,
      ),
    );
  }

  // Plant info
  Widget _buildPlantInfo() {
    return Text(
      widget.plantName,
      style: const TextStyle(
        color: Color(0xFF757575),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // Instructions for the visitor
  Widget _buildInstructions() {
    return Text(
      'Before taking your access pass test, please view and read our safety materials to fully understand the safety rules at our plant sites.',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF343434),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }

  // Download button
  Widget _buildDownloadButton() {
    return InkWell(
      onTap: () {
        _showDocument(context);  // Panggil untuk menampilkan dokumen PDF
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'View Induction Material',
            style: TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF07840B),
            ),
          ),
        ),
      ),
    );
  }
  // Widget _buildDownloadButton() {
  //   return ElevatedButton(
  //     onPressed: () => _showDocument(context),
  //     style: ElevatedButton.styleFrom(
  //       side: BorderSide(color: Colors.grey),
  //       backgroundColor: Colors.white,
  //       padding: EdgeInsets.symmetric(vertical: 12),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     ),
  //     child: Text(
  //       'Download Induction Material',
  //       style: TextStyle(
  //         fontFamily: 'Hanken Grotesk',
  //         fontSize: 16.0,
  //         fontWeight: FontWeight.w700,
  //         color: Color(0xFF07840B),
  //       ),
  //     ),
  //   );
  // }


  // Confirmation button
  Widget _buildConfirmationButton() {
    return InkWell(
      onTap: isDocumentRead ? () {

        context.push(
          '/welcome-test-intructions',
          extra: {
            'idrequest': widget.idrequest,
            'plantId': widget.plantId,
            'plantName': widget.plantName,
          },
        );
      } : null,  // Disable button jika dokumen belum dibaca
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          color: isDocumentRead ? Color(0xFF07840B) : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Text(
            'I have read and understood the safety rules of the plant sites.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return InkWell(
      onTap: () {
        // Pastikan logika yang ada disini hanya dijalankan saat kondisi sudah benar
        context.go(
          '/welcome-test-intructions',
          extra: {
            'idrequest': widget.idrequest,
            'plantId': widget.plantId,
            'plantName': widget.plantName,
          },
        );
      },
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.blue,  // Warna tombol yang selalu aktif
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            'I have read and understood the safety rules of the plant sites.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Colors.white, // Teks tetap putih
            ),
          ),
        ),
      ),
    );
  }

  // Function untuk menampilkan dokumen
  void _showDocument(BuildContext context) async {
    setState(() {isLoading = true;
    });
    // URL dokumen PDF
    String documentUrl = 'https://drive.google.com/uc?export=download&id=1qMD67WKbjXRwBJzUwdUka0fX6K_QEGgT';

    try {
      // Menyimpan file PDF sementara
      Dio dio = Dio();
      Directory appDocDir = await getTemporaryDirectory();
      String savePath = '${appDocDir.path}/induction_material.pdf';

      // Mendownload file
      await dio.download(documentUrl, savePath);
      setState(() {
        isLoading = false;
      });

      // Menampilkan PDF setelah diunduh
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewPage(
            filePath: savePath,
            onFinishedReading: () {
              setState(() {
                isDocumentRead = true;
              });
            },
          ),
        ),
      );
    } catch (e) {
      // Menangani error jika gagal mendownload file
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download document: $e')),
      );
    }
  }

  // void _showDocumentWeb(BuildContext context) {
  //   String documentUrl = 'https://drive.google.com/file/d/1qMD67WKbjXRwBJzUwdUka0fX6K_QEGgT/view?usp=sharing';
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         contentPadding: EdgeInsets.zero,
  //         insetPadding: const EdgeInsets.all(16.0),
  //         content: SizedBox(
  //           width: 800, // Sesuaikan ukuran popup
  //           height: 600,
  //           child: Column(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(8.0),
  //                 color: Colors.grey.shade200,
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text(
  //                       'Dokumen PDF',
  //                       style: TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.close),
  //                       onPressed: () => Navigator.of(context).pop(),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const Divider(height: 1, thickness: 1),
  //               Expanded(
  //                 child: HtmlElementView(
  //                   viewType: 'iframe',
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //
  //   // Membuat iframe untuk menampilkan dokumen PDF
  //   final html.IFrameElement iframe = html.IFrameElement()
  //     ..src = documentUrl
  //     ..style.border = 'none';
  //
  //   // Mendaftarkan IFrame pada platform view registry
  //   ui.platformViewRegistry.registerViewFactory(
  //     'iframe',
  //         (int viewId) => iframe,
  //   );
  // }

}

class PDFViewPage extends StatelessWidget {
  final String filePath;
  final VoidCallback onFinishedReading;

  const PDFViewPage({super.key, required this.filePath, required this.onFinishedReading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Induction Material')),
      body: PDFView(
        filePath: filePath,
        onPageError: (page, error) {
          print('Error loading page $page: $error');
        },
        onPageChanged: (int? currentPage, int? totalPages) {
          if (currentPage == totalPages! - 1) {  // Memastikan currentPage dan totalPages tidak null
            onFinishedReading();
          }
        },
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String filePath;

  const PDFViewerPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: filePath,
        onPageError: (page, error) {
          print('Error loading page $page: $error');
        },
        // onPageChanged: (int? currentPage, int? totalPages) {
        //   if (currentPage == totalPages! - 1) {  // Memastikan currentPage dan totalPages tidak null
        //     onFinishedReading();
        //   }
        // },
      ),
    );
  }
}