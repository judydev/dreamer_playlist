import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/helpers/audio_handler.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

ValueNotifier<int?> currentIndexNotifier = ValueNotifier(null);
MediaItem? getCurrentPlaying(int? currentIndex) {
  if (currentIndex == null) return null;
  List<MediaItem> playlist = GetitUtil.audioHandler.queue.value;
  if (playlist.length > currentIndex) {
    return GetitUtil.audioHandler.queue.value[currentIndex];
  }
  debugPrint('getCurrentPlaying index out of range');
  currentIndexNotifier.value = null;
  return null;
}

// used to refresh the music queue
ValueNotifier<List<int>> queueIndicesNotifier = ValueNotifier([]);

// loopModeNotifier: to refresh the loop button in MusicQueue
ValueNotifier<LoopMode> loopModeNotifier = ValueNotifier(LoopMode.off);

// to refresh the play/pause button in PlayerButtonbar
enum PlayingState { playing, paused }

ValueNotifier<PlayingState> playingStateNotifier =
    ValueNotifier(PlayingState.paused);

ValueNotifier<ShuffleMode> shuffleModeNotifier = ValueNotifier(ShuffleMode.off);

ValueNotifier<double> progressBarValueNotifier = ValueNotifier(0);

enum ShuffleMode { on, off }

MyAudioHandler _audioHandler = GetitUtil.audioHandler;

// debugging functions
printSongListFromIndices(List<int>? indices) {
  if (indices == null) {
    return _audioHandler.queue.value.map((e) => e.title).toList();
  }

  List res = indices.map((i) => _audioHandler.queue.value[i].title).toList();
  print('new songlist = $res');
}
