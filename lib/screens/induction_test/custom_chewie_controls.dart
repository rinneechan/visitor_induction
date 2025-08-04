import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class NoSeekControls extends StatefulWidget {
  const NoSeekControls({Key? key}) : super(key: key);

  @override
  _NoSeekControlsState createState() => _NoSeekControlsState();
}

class _NoSeekControlsState extends State<NoSeekControls> {
  ChewieController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = ChewieController.of(
        context); // Mengambil controller setelah dependensi terpasang
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      color: Colors.transparent,
      child: Center(
        child: IconButton(
          icon: Icon(
            _controller!.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 40.0,
          ),
          onPressed: () {
            if (_controller!.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          },
        ),
      ),
    );
  }
}
