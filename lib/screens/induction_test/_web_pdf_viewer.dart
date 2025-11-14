// lib/screens/induction_test/web_pdf_viewer.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
      appBar: AppBar(title: const Text('Induction Material')),
      body: SfPdfViewer.network(
        widget.documentUrl,
        controller: _pdfViewerController,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
        },
      ),
    );
  }
}
