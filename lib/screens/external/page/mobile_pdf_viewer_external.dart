import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class MobilePdfViewerExternal extends StatelessWidget {
  final String localPath;
  final VoidCallback? onFinishedReading;

  const MobilePdfViewerExternal({
    super.key,
    required this.localPath,
    this.onFinishedReading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (onFinishedReading != null) {
              onFinishedReading!();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: PDFView(
        filePath: localPath,
      ),
    );
  }
}
