import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

ValueNotifier<Song?> currentlyPlayingNotifier = ValueNotifier(null);

// used to refresh the music queue
ValueNotifier<List<int>> queueIndicesNotifier = ValueNotifier([]);

List<int> updateQueueIndices() {
  List<int> playingNextIndices = [];
  List<int> effectiveIndices = _audioPlayer.effectiveIndices ?? [];

  int currentIndex = _audioPlayer.currentIndex ?? 0;
  switch (loopModeNotifier.value) {
    case LoopMode.off:
      if (_audioPlayer.currentIndex != null) {
        if (currentIndex < effectiveIndices.length) {
          if (currentlyPlayingNotifier.value == null) {
            playingNextIndices = effectiveIndices.sublist(currentIndex);
          } else {
            playingNextIndices = effectiveIndices.sublist(currentIndex + 1);
          }
        } else {
          playingNextIndices = [];
        }
      } else {
        playingNextIndices = effectiveIndices;
      }
      break;
    case LoopMode.one:
    case LoopMode.all:
    default:
      playingNextIndices = effectiveIndices;
  }

  queueIndicesNotifier.value = List.from(playingNextIndices);
  return playingNextIndices;
}

// loopModeNotifier: to refresh the loop button in MusicQueue
ValueNotifier<LoopMode> loopModeNotifier = ValueNotifier(LoopMode.off);

AudioPlayer _audioPlayer = GetitUtil.audioPlayer;
// to refresh the play/pause button in PlayerButtonbar
enum PauseState { playing, paused }

ValueNotifier<PauseState> pauseStateNotifier = ValueNotifier(PauseState.paused);

ValueNotifier<ShuffleMode> shuffleModeNotifier = ValueNotifier(
    _audioPlayer.shuffleModeEnabled ? ShuffleMode.on : ShuffleMode.off);

enum ShuffleMode { on, off }
void updateShuffleModeNotifier() {
  shuffleModeNotifier.value =
      _audioPlayer.shuffleModeEnabled ? ShuffleMode.on : ShuffleMode.off;
}

// enum PlayerMode { mini, full }

// debugging functions
printSongListFromIndices(List<int>? indices) {
  if (indices == null) {
    return;
  }

  List res = indices.map((i) => _audioPlayer.sequence![i].tag.name).toList();
  print('new songlist = $res');
}
