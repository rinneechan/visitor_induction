import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionMaterialById.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';


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

  @override
  void initState() {
    super.initState();
    _futureMaterials = ApiService().materiByIdrequest(widget.idmateri);
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
            final String pdfUrl = Uri.encodeFull(material.linkData);
            // return SfPdfViewer.network(
            //   material.linkData,
            //   key: Key(material.idMateri.toString()),
            //
            // );
            // return SfPdfViewer.network(
            //   pdfUrl,
            //   key: Key(material.idMateri.toString()),
            //   onDocumentLoadFailed: (details) {
            //     print('Error loading PDF: ${details.description}');
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text('Failed to load PDF: ${details.description}')),
            //     );
            //   },
            // );
            return PDFView(
              filePath: material.linkData,
              onError: (error) {
                print('PDF load error: $error');
              },
              onPageError: (page, error) {
                print('Page $page load error: $error');
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
