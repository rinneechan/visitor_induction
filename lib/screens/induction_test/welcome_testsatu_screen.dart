import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'video_player_page.dart';

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
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token');

      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/chooseaccess');
      }
    });
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double bodyWidth = MediaQuery.of(context).size.width * 0.5;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // appBar: _buildAppBar(bodyWidth),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double bodyWidth) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SvgPicture.asset(
                    'assets/images/logo-cg.svg',
                    height: 35.0,
                    placeholderBuilder: (context) =>
                        CircularProgressIndicator(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  'CEMINDO GEMILANG',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB0191F),
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
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

  // Widget _buildBody() {
  //   return Center(
  //     child: Container(
  //       width: MediaQuery.of(context).size.shortestSide,
  //       height: MediaQuery.of(context).size.height,
  //       child: Stack(
  //         children: [
  //           Container(color: Colors.white),
  //           Positioned(
  //             top: 5,
  //             left: 0,
  //             right: 0,
  //             child: Card(
  //               color: Colors.white,
  //               margin: const EdgeInsets.symmetric(horizontal: 0),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(0),
  //               ),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(16.0),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     _buildHeader(),
  //                     const SizedBox(height: 24),
  //                     _buildHeaderTitle(),
  //                     const SizedBox(height: 24),
  //                     _buildUserGreeting(),
  //                     const SizedBox(height: 24),
  //                     _buildCG(),
  //                     const SizedBox(height: 24),
  //                     _buildPlantInfo(),
  //                     const SizedBox(height: 24),
  //                     _buildInstructions(),
  //                     const SizedBox(height: 24),
  //                     _buildDownloadButton(),
  //                     const SizedBox(height: 24),
  //                     _buildConfirmationButton(),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           if (isLoading)
  //             Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.shortestSide,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(color: Colors.white),
            Positioned(
              top: 5,
              left: 0,
              right: 0,
              bottom: 0, // tambahkan agar batas bawah terdeteksi
              child: SingleChildScrollView(
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
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        //Divider(color: Colors.grey, thickness: 1.0),
        // const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kiri: Icon + Logo CG + Text
              Row(
                children: [
                  // Icon(Icons.business,
                  //     color: Color(0xFFB0191F), size: 30), // Ikon di kiri
                  // const SizedBox(width: 8.0),
                  SvgPicture.asset(
                    'assets/images/logo-cg.svg',
                    height: 35.0,
                    placeholderBuilder: (context) =>
                        CircularProgressIndicator(),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'CEMINDO GEMILANG',
                    style: const TextStyle(
                      fontSize: 11.42,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB0191F),
                      fontFamily: 'Lato',
                    ),
                  ),
                ],
              ),

              // Kanan: Logo Sedia
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
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
        const SizedBox(height: 8),
        // Divider(color: Colors.grey, thickness: 1.0),
      ],
    );
  }

  Widget _buildHeaderTitle() {
    return Column(
      children: [
        Divider(color: Colors.grey, thickness: 1.0),
        const SizedBox(height: 8),
        Text(
          'VISITOR INDUCTIONS',
          style: const TextStyle(
            color: Color(0xFF07840B),
            fontFamily: 'Hanken Grotesk',
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey, thickness: 1.0),
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

  // Instructions for the visitor
  Widget _buildInstructions() {
    return Text(
      'Before taking your access pass test, please download and read our safety materials to fully understand the safety rules at our plant sites.',
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

  Widget _buildDownloadButton() {
    return InkWell(
      onTap: () {
        _showDocument(context, widget.plantId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Download Induction Material',
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

  Widget _buildConfirmationButton() {
    return InkWell(
      onTap: isDocumentRead
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
          : null, // Disable button jika dokumen belum dibaca
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          color: isDocumentRead
              ? Color(0xFF07840B)
              : Colors.grey, // Tombol disabled abu-abu
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
              color: isDocumentRead
                  ? Colors.white
                  : Colors.black54, // Warna teks berubah saat disabled
            ),
          ),
        ),
      ),
    );
  }

  void _showDocument(BuildContext context, String byplant) async {
    setState(() {
      isLoading = true;
    });

    try {
      ApiService apiService = ApiService();
      final response = await apiService.materiByPlant(byplant);

      if (response.isEmpty) {
        throw Exception('No document URL found');
      }

      String documentUrl = response[0].linkData;

      setState(() {
        isLoading = false;
      });
      // print("File yang didapat: $documentUrl");
      final extension =
          documentUrl.split('.').last.split('?').first.toLowerCase();

      if (extension == 'mp4') {
        // print("Ini adalah file video, navigasi ke VideoPlayerPage");
        // Jika file video
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(
              videoUrl: documentUrl,
              onFinishedWatching: () {
                setState(() {
                  isDocumentRead = true;
                });
              },
            ),
          ),
        );
      } else if (extension == 'pdf') {
        if (kIsWeb) {
          setState(() {
            isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebPdfViewer(
                documentUrl: documentUrl,
                onFinishedReading: () {
                  setState(() {
                    isDocumentRead = true;
                  });
                },
              ),
            ),
          );
        } else {
          print("Mulai download PDF dari: $documentUrl");

          Dio dio = Dio();
          Directory appDocDir = await getTemporaryDirectory();
          String savePath = '${appDocDir.path}/induction_material.pdf';

          await dio.download(documentUrl, savePath);
          print("PDF berhasil didownload di: $savePath");

          if (!context.mounted) return;

          setState(() {
            isLoading = false;
          });

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
        }
      }
    } catch (e, stacktrace) {
      print("Error loading document: $e\n$stacktrace");

      if (!context.mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load document: $e')),
      );
    }
  }
}

class PDFViewPage extends StatefulWidget {
  final String filePath;
  final Function() onFinishedReading;

  const PDFViewPage({
    super.key,
    required this.filePath,
    required this.onFinishedReading,
  });

  @override
  _PDFViewPageState createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  int _totalPages = 1;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Induction Material')),
      body: PDFView(
        filePath: widget.filePath,
        onRender: (pages) {
          setState(() {
            _totalPages = pages!;
          });
        },
        onPageChanged: (page, _) {
          setState(() {
            _currentPage = page!;
          });

          if (_currentPage == _totalPages - 1) {
            widget.onFinishedReading();
          }
        },
      ),
    );
  }
}

class WebPdfViewer extends StatefulWidget {
  final String documentUrl;
  final Function() onFinishedReading;

  const WebPdfViewer({
    super.key,
    required this.documentUrl,
    required this.onFinishedReading,
  });

  @override
  _WebPdfViewerState createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<WebPdfViewer> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _pdfViewerController.addListener(() {
      if (_pdfViewerController.pageNumber == _totalPages) {
        widget.onFinishedReading();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Induction Material')),
      body: SingleChildScrollView(
        // Membuat tampilan scrollable
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Menyesuaikan tinggi
          child: SfPdfViewer.network(
            widget.documentUrl,
            controller: _pdfViewerController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _totalPages = details.document.pages.count;
              });
            },
          ),
        ),
      ),
    );
  }
}

// class _WebPdfViewerState extends State<WebPdfViewer> {
//   final PdfViewerController _pdfViewerController = PdfViewerController();
//   int _totalPages = 1;

//   @override
//   void initState() {
//     super.initState();
//     _pdfViewerController.addListener(() {
//       if (_pdfViewerController.pageNumber == _totalPages) {
//         widget.onFinishedReading();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Induction Material')),
//       body: SfPdfViewer.network(
//         widget.documentUrl,
//         controller: _pdfViewerController,
//         onDocumentLoaded: (PdfDocumentLoadedDetails details) {
//           setState(() {
//             _totalPages = details.document.pages.count;
//           });
//         },
//       ),
//     );
//   }
// }
