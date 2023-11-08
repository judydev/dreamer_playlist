import 'package:dreamer_playlist/models/playlist.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

ValueNotifier<int?> currentIndexNotifier = ValueNotifier(null);

// used to refresh the music queue
ValueNotifier<List<int>> queueIndicesNotifier = ValueNotifier([]);

// loopModeNotifier: to refresh the loop button in MusicQueue
ValueNotifier<LoopMode> loopModeNotifier = ValueNotifier(LoopMode.off);

// to refresh the play/pause button in PlayerButtonbar
enum PlayingState { playing, paused, loading }

ValueNotifier<PlayingState> playingStateNotifier =
    ValueNotifier(PlayingState.paused);

ValueNotifier<bool> shuffleModeNotifier = ValueNotifier(false);

final selectedFavoritePlaylistNotifier = ValueNotifier<Playlist?>(null);

