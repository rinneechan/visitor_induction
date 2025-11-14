// lib/screens/induction_test/web_pdf_viewer.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data'; // Import Uint8List

class WebPdfViewer extends StatefulWidget {
  final Uint8List pdfBytes; // Menerima Uint8List
  final Function() onFinishedReading;

  const WebPdfViewer({
    super.key,
    required this.pdfBytes, // Harus berupa Uint8List
    required this.onFinishedReading,
  });

  @override
  _WebPdfViewerState createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<WebPdfViewer> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _totalPages = 1;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pdfViewerController.addListener(() {
      if (_pdfViewerController.pageNumber == _totalPages) {
        widget.onFinishedReading(); // Panggil saat halaman terakhir dicapai
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Induction Material'),
        actions: [
          // Tombol centang bisa ditambahkan di sini jika diperlukan,
          // tapi fungsionalitas utama adalah saat mencapai halaman terakhir
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat PDF: $_error',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ],
              ),
            )
          else
            // GUNAKAN SfPdfViewer.memory
            SfPdfViewer.memory(
              widget.pdfBytes, // Gunakan Uint8List secara langsung
              controller: _pdfViewerController,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _totalPages = details.document.pages.count;
                  _isLoading = false;
                });
              },
              onDocumentLoadFailed: (dynamic error) {
                setState(() {
                  _isLoading = false;
                  _error = error.toString();
                });
              },
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}