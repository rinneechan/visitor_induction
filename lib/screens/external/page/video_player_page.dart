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
    initPlayer();
  }

  Future<void> initPlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    // ⬇️ WAJIB: iPhone Safari butuh mute untuk autoplay
    await _videoController.setVolume(0);

    // initialize
    await _videoController.initialize();

    // Chewie controller
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,

      // ⬇️ FIX untuk Safari Web iPhone
      allowFullScreen: false,
      allowMuting: true,
      autoInitialize: true,
      showControlsOnInitialize: true,

      // Boleh diubah sesuai internal
      allowPlaybackSpeedChanging: false,
      additionalOptions: (_) => [],
    );

    // detect selesai nonton
    _videoController.addListener(() {
      final value = _videoController.value;
      if (value.position >= value.duration && !value.isPlaying) {
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
