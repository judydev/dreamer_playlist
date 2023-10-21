import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends StatefulWidget {
  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late AudioPlayer _player;
  late bool isPlaying;

  String songName = "Not playing";

  @override
  void initState() {
    super.initState();

    _player = GetIt.instance.get<AudioPlayer>();
    if (_player.audioSource != null) {
      List<IndexedAudioSource> sequence = _player.audioSource!.sequence;
      if (_player.currentIndex != null) {
        songName = sequence[_player.currentIndex!].tag;
      }
    }

    isPlaying = _player.playing;
  }

  updateSongName() {
    // move this to the player handler
    late String tag;
    if (_player.audioSource != null) {
      List<IndexedAudioSource> sequence = _player.audioSource!.sequence;
      if (_player.currentIndex != null) {
        tag = sequence[_player.currentIndex!].tag;
      }
    }

    if (tag != songName) {
      setState(() {
        songName = tag;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Spacer(),
      IconButton(
          onPressed: () {
            updateSongName();
            _player.seekToPrevious();
            _player.play();
          },
          icon: Icon(Icons.skip_previous)),
      Spacer(),
      Text(songName),
      Spacer(),
      IconButton(
          onPressed: () {
            updateSongName();
            _player.seekToNext();
          },
          icon: Icon(Icons.skip_next)),
      IconButton(
          onPressed: () {
            if (isPlaying) {
              print('miniplayer pause');
              _player.pause();
            } else {
              print('miniplayer play');
              _player.play();
            }
            setState(() {
              isPlaying = !isPlaying;
            });
          },
          icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow)),
      Spacer(),
    ]);
  }
}
