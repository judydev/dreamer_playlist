import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

ValueNotifier<Song?> currentlyPlayingNotifier = ValueNotifier(null);

ValueNotifier<List<int>?> effectiveIndicesNotifier = ValueNotifier(null);
void updateEffectiveIndicesNotifier() {
  effectiveIndicesNotifier.value = GetitUtil.audioPlayer.effectiveIndices;
}

ValueNotifier<LoopMode> loopModeNotifier = ValueNotifier(LoopMode.off);

AudioPlayer _audioPlayer = GetitUtil.audioPlayer;
ValueNotifier<PlayerState> playerStateNotifier = ValueNotifier(
    PlayerState(_audioPlayer.playing, _audioPlayer.processingState));

ValueNotifier<ShuffleMode> shuffleModeNotifier = ValueNotifier(
    _audioPlayer.shuffleModeEnabled ? ShuffleMode.on : ShuffleMode.off);

void updateShuffleModeNotifier() {
  shuffleModeNotifier.value =
      _audioPlayer.shuffleModeEnabled ? ShuffleMode.on : ShuffleMode.off;
}

enum PlayerMode { mini, full }

enum ShuffleMode { on, off }
