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
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.videoUrl);

    try {
      await _videoController.initialize();

      // Listener: Detect video selesai
      _videoController.addListener(() {
        final isEnded =
            _videoController.value.position >= _videoController.value.duration &&
                !_videoController.value.isPlaying;

        if (isEnded) {
          widget.onFinishedWatching(); // Trigger welcome screen
        }
      });

      // Chewie setup
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowPlaybackSpeedChanging: true, // <= SPEED ENABLED
        allowMuting: true,
        playbackSpeeds: const [
          0.5,
          1.0,
          1.25,
          1.5,
          1.75,
          2.0,
        ],
      );

      setState(() {});
    } catch (e) {
      debugPrint("❌ Video load error: $e");
      setState(() {});
    }
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
      appBar: AppBar(title: const Text('Video Induction')),
      body: Center(
        child: _chewieController != null &&
                _videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            : _videoController.value.hasError
                ? const Text(
                    "Gagal memuat video",
                    style: TextStyle(color: Colors.red),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
