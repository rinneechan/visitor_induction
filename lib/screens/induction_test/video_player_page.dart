import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';

import 'dart:ui_web' as ui_web; // FIX platformViewRegistry
import 'dart:html' as html;      // Untuk HTML5 video pada iPhone Safari

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

  // ------------ DETEKSI iPHONE SAFARI ------------
  bool get isIOSWeb {
    if (!kIsWeb) return false;
    final ua = html.window.navigator.userAgent.toLowerCase();
    return ua.contains("iphone") || ua.contains("ipad") || ua.contains("ipod");
  }

  // ------------ HTML5 VIDEO UNTUK iPHONE ------------
  Widget _buildHtmlVideoPlayer() {
    final videoEl = html.VideoElement()
      ..src = widget.videoUrl
      ..autoplay = true
      ..controls = true
      ..muted = true // autoplay wajib mute
      ..setAttribute("playsinline", "true")
      ..setAttribute("webkit-playsinline", "true")
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.border = "none";

    final viewId = "html-video-${widget.videoUrl}";

    // FIX: pakai ui_web.platformViewRegistry
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => videoEl,
    );

    videoEl.onEnded.listen((event) {
      widget.onFinishedWatching();
      if (mounted) Navigator.pop(context);
    });

    return HtmlElementView(viewType: viewId);
  }

  // ------------ FLUTTER VIDEO PLAYER UNTUK ANDROID/WEB ------------
  Future<void> initPlayer() async {
    if (isIOSWeb) {
      setState(() {}); // langsung render HTML video
      return;
    }

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    await _videoController.setVolume(0); // autoplay fix
    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: false,
      allowMuting: true,
      showControlsOnInitialize: true,
      allowPlaybackSpeedChanging: false,
    );

    _videoController.addListener(() {
      final v = _videoController.value;

      if (!hasStartedPlaying && v.isPlaying && v.position > Duration.zero) {
        hasStartedPlaying = true;
      }

      if (!hasStartedPlaying) return;

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
    if (!isIOSWeb) {
      _videoController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Induction")),
      body: Center(
        child: isIOSWeb
            ? _buildHtmlVideoPlayer() // <-- iPhone Safari pakai HTML video
            : (_chewieController != null &&
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
