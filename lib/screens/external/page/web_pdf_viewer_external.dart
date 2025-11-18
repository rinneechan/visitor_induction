import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';

class WebPdfViewerExternal extends StatefulWidget {
  final Uint8List pdfBytes;
  final VoidCallback onFinishedReading;

  const WebPdfViewerExternal({
    super.key,
    required this.pdfBytes,
    required this.onFinishedReading,
  });

  @override
  _WebPdfViewerExternalState createState() => _WebPdfViewerExternalState();
}

class _WebPdfViewerExternalState extends State<WebPdfViewerExternal> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _totalPages = 1;
  bool _isLoading = true;
  String? _error;

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
      appBar: AppBar(
        title: const Text("Induction Material (PDF)"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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
                  Text("Gagal memuat PDF:\n$_error",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            )
          else
            SfPdfViewer.memory(
              widget.pdfBytes,
              controller: _pdfViewerController,
              onDocumentLoaded: (details) {
                setState(() {
                  _totalPages = details.document.pages.count;
                  _isLoading = false;
                });
              },
              onDocumentLoadFailed: (error) {
                setState(() {
                  _error = error.toString();
                  _isLoading = false;
                });
              },
            ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
