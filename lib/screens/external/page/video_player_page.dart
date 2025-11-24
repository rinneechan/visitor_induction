import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';

import 'dart:ui_web' as ui_web; // FIX untuk registerViewFactory
import 'dart:html' as html;      // dipakai untuk HTML5 video pada Safari iOS

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

  // ----------------------------
  // DETEKSI iPHONE WEB
  // ----------------------------
  bool get isIOSWeb {
    if (!kIsWeb) return false;
    final ua = html.window.navigator.userAgent.toLowerCase();
    return ua.contains("iphone") ||
        ua.contains("ipad") ||
        ua.contains("ipod");
  }

  // ----------------------------
  // HTML5 VIDEO UNTUK iPHONE
  // ----------------------------
  Widget _buildHtmlVideoPlayer() {
    final videoEl = html.VideoElement()
      ..src = widget.videoUrl
      ..autoplay = true
      ..controls = true
      ..muted = true
      ..setAttribute("playsinline", "true")
      ..setAttribute("webkit-playsinline", "true")
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.border = "none";

    // Daftarkan sebagai view
    final viewId = "html-video-external-${widget.videoUrl}";

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => videoEl,
    );

    // Deteksi selesai
    videoEl.onEnded.listen((event) {
      widget.onFinishedWatching();
      if (mounted) Navigator.pop(context);
    });

    return HtmlElementView(viewType: viewId);
  }

  // ----------------------------
  // CHEWIE VIDEO FOR ANDROID/WEB
  // ----------------------------
  Future<void> initPlayer() async {
    if (isIOSWeb) {
      // Safari iPhone → langsung pakai HTML video
      setState(() {});
      return;
    }

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    // Wajib mute untuk autoplay di Safari (meski Safari tidak dipakai di Chewie)
    await _videoController.setVolume(0);

    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: false,
      allowMuting: true,
      autoInitialize: true,
      showControlsOnInitialize: true,
      allowPlaybackSpeedChanging: false,
    );

    _videoController.addListener(() {
      final v = _videoController.value;

      // Deteksi selesai nonton
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
    if (!isIOSWeb) {
      _videoController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  // ----------------------------
  // BUILD UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Induction")),
      body: Center(
        child: isIOSWeb
            ? _buildHtmlVideoPlayer() // <-- Safari iPhone
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
