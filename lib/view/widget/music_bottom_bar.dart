import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:itunes_clone/model/song.dart';

class MusicBottomBar extends StatefulWidget {
  final Song? song;
  final void Function() onPlay;
  final void Function() onPause;

  const MusicBottomBar({
    super.key,
    required this.song,
    required this.onPlay,
    required this.onPause,
  });

  @override
  State<MusicBottomBar> createState() => _MusicBottomBarState();
}

class _MusicBottomBarState extends State<MusicBottomBar> {
  final AudioPlayer _audioPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  void _changeSong() async {
    _audioPlayer.stop();
    _audioPlayer.play(UrlSource(widget.song?.previewUrl ?? ""));
  }

  Widget _buildPreviewImage() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      height: Get.height * 0.075,
      width: Get.height * 0.075,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.song == null
          ? const Icon(Icons.music_note)
          : Image.network(widget.song?.artworkUrl100 ?? ""),
    );
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        widget.onPause();
      } else if (state == PlayerState.playing) {
        widget.onPlay();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MusicBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.song != oldWidget.song) {
      _changeSong();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.15,
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPreviewImage(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.song?.trackName ?? "Not Playing",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              if (widget.song == null) return;
              if (widget.song!.isPlaying) {
                _audioPlayer.pause();
                widget.onPause();
              } else {
                _audioPlayer.resume();
                widget.onPlay();
              }
            },
            child: Icon(
              widget.song?.isPlaying ?? false ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
