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

    // 🔥 WAJIB: Safari Web hanya izinkan autoplay jika video mute
    await _videoController.setVolume(0);

    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,

      // Fix Safari iPhone
      allowFullScreen: false,
      allowMuting: true,
      autoInitialize: true,
      showControlsOnInitialize: true,

      // Konsisten dengan internal
      allowPlaybackSpeedChanging: false,
      additionalOptions: (_) => [],
    );

    // 🔥 FIX: Deteksi selesai nonton dengan error margin
    _videoController.addListener(() {
      final v = _videoController.value;

      if (!isFinished &&
          v.position.inMilliseconds >= (v.duration.inMilliseconds - 500) &&
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
