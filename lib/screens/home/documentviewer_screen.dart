import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentViewer extends StatelessWidget {
  final String fileUrl;
  final String namaFile;

  const DocumentViewer({Key? key, required this.fileUrl, required this.namaFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(namaFile),
      ),
      //body: SfPdfViewer.network(fileUrl),
      body: SfPdfViewer.network('https://drive.google.com/uc?export=download&id=1qMD67WKbjXRwBJzUwdUka0fX6K_QEGgT'),

    );
  }
}
