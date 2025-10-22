import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionMaterialById.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'fullscreen_video_player.dart';

class DocumentViewer extends StatefulWidget {
  final String idmateri;
  final String namaFile;

  const DocumentViewer({
    super.key,
    required this.idmateri,
    required this.namaFile,
  });

  @override
  _DocumentViewerState createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  late Future<List<InductionMaterialBy>> _futureMaterials;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _futureMaterials = ApiService().materiByIdrequest(widget.idmateri);
  }

  Future<String> _downloadFile(String url, String extension) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = "${dir.path}/temp_${widget.idmateri}.$extension";
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception(
            "Failed to download file. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error downloading file: $e");
    }
  }

  Widget _buildVideoPlayer(String url) {
    if (kIsWeb) {
      _videoController = VideoPlayerController.network(url);
    } else {
      _videoController = VideoPlayerController.file(File(url));
    }

    return FutureBuilder(
      future: _videoController!.initialize().then((_) {
        _videoController!.play();

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) =>
        //           FullScreenVideoPlayer(controller: _videoController!),
        //     ),
        //   );
        // });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  FullScreenVideoPlayer(controller: _videoController!),
            ),
          ).then((_) {
            // Setelah video ditutup, kembali ke halaman sebelumnya
            Navigator.pop(context); // ini akan menutup DocumentViewer
          });
        });
      }),
      builder: (context, snapshot) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
            final url = material.linkData;
            final extension =
                url.split('.').last.split('?').first.toLowerCase();

            if (extension == 'pdf') {
              if (kIsWeb) {
                return SfPdfViewer.network(url);
              } else {
                return FutureBuilder<String>(
                  future: _downloadFile(url, 'pdf'),
                  builder: (context, fileSnapshot) {
                    if (fileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (fileSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${fileSnapshot.error}'));
                    } else {
                      return SfPdfViewer.file(File(fileSnapshot.data!));
                    }
                  },
                );
              }
            } else if (extension == 'mp4') {
              if (kIsWeb) {
                return _buildVideoPlayer(url);
              } else {
                return FutureBuilder<String>(
                  future: _downloadFile(url, 'mp4'),
                  builder: (context, fileSnapshot) {
                    if (fileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (fileSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${fileSnapshot.error}'));
                    } else {
                      return _buildVideoPlayer(fileSnapshot.data!);
                    }
                  },
                );
              }
            } else {
              return const Center(child: Text('Unsupported file type.'));
            }
          } else {
            return const Center(child: Text('No document available.'));
          }
        },
      ),
    );
  }
}
