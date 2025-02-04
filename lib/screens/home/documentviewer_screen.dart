import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionMaterialById.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class DocumentViewer extends StatefulWidget {
  final String idmateri;
  final String namaFile;

  const DocumentViewer({
    Key? key,
    required this.idmateri,
    required this.namaFile,
  }) : super(key: key);

  @override
  _DocumentViewerState createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  late Future<List<InductionMaterialBy>> _futureMaterials;
  String? _localPdfPath;

  @override
  void initState() {
    super.initState();
    _futureMaterials = ApiService().materiByIdrequest(widget.idmateri);
  }

  // Fungsi untuk mengunduh file PDF
  Future<String> _downloadPDF(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = "${dir.path}/temp_${widget.idmateri}.pdf";
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception("Failed to download PDF. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error downloading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.namaFile)),
      body: FutureBuilder<List<InductionMaterialBy>>(
        future: _futureMaterials,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final material = snapshot.data!.first;
            print("PDF URL: ${material.linkData}");

            return FutureBuilder<String>(
              future: _downloadPDF(material.linkData),
              builder: (context, fileSnapshot) {
                if (fileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (fileSnapshot.hasError) {
                  return Center(child: Text('Error downloading file: ${fileSnapshot.error}'));
                } else {
                  _localPdfPath = fileSnapshot.data;
                  return SfPdfViewer.file(File(_localPdfPath!));
                }
              },
            );
          } else {
            return const Center(child: Text('No document available.'));
          }
        },
      ),
    );
  }
}
