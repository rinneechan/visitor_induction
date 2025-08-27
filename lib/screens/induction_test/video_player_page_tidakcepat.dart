import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'custom_chewie_controls.dart'; // custom controls tanpa seek

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onFinishedWatching;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.onFinishedWatching,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    // Sembunyikan status dan nav bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

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
          allowFullScreen: false, // Sudah fullscreen dari awal
          showControlsOnInitialize: true,
          allowMuting: false,
          allowPlaybackSpeedChanging: false,
          customControls:
              const NoSeekControls(), // ← gunakan kontrol tanpa seek
        );
        setState(() {});
      }).catchError((e) {
        debugPrint("Video error: $e");
      });
  }

  @override
  void dispose() {
    // Kembalikan UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Cegah back button
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Disable tombol back
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _chewieController != null && _videoController.value.isInitialized
            ? SizedBox.expand(
                child: Chewie(controller: _chewieController!),
              )
            : _videoController.value.hasError
                ? const Center(
                    child: Text("Gagal memuat video",
                        style: TextStyle(color: Colors.white)))
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
