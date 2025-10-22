import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onFinishedWatching;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.onFinishedWatching,
  });

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        final isEnded = _videoController.value.position >=
                _videoController.value.duration &&
            !_videoController.value.isPlaying;

        if (isEnded) {
          widget.onFinishedWatching();
        }
      })
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
        );
        setState(() {});
      }).catchError((e) {
        debugPrint("Video error: $e");
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Induction')),
      body: Center(
        child: _chewieController != null && _videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            : _videoController.value.hasError
                ? Text("Gagal memuat video")
                : CircularProgressIndicator(),
      ),
    );
  }
}
