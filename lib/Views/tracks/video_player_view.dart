import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoContentPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoContentPage({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoContentPage> createState() => _VideoContentPageState();
}

class _VideoContentPageState extends State<VideoContentPage> {
  late YoutubePlayerController _controller;
  late String _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? "";
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text("Invalid YouTube URL")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.redAccent,
        ),
        builder: (context, player) {
          return Column(
            children: [
              player,
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
