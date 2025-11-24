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

  bool hasStartedPlaying = false;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    // Untuk autoplay Safari iPhone
    await _videoController.setVolume(0);

    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: false, // iPhone Safari sering error
      allowMuting: true,
      showControlsOnInitialize: true,
      allowPlaybackSpeedChanging: false,
    );

    // Listener diperbaiki
    _videoController.addListener(() {
      final v = _videoController.value;

      // Safari fix: tunggu sampai benar-benar mulai play
      if (!hasStartedPlaying && v.isPlaying && v.position > Duration.zero) {
        hasStartedPlaying = true;
      }

      // Jangan deteksi selesai sebelum mulai play
      if (!hasStartedPlaying) return;

      // Deteksi selesai menonton
      if (!isFinished &&
          v.duration > Duration.zero &&
          v.position >= v.duration &&
          !v.isPlaying) {
        isFinished = true;
        widget.onFinishedWatching();
        if (mounted) Navigator.pop(context);
      }
    });

    setState(() {});
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
      appBar: AppBar(title: const Text("Video Induction")),
      body: Center(
        child: (_chewieController != null &&
                _videoController.value.isInitialized)
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
