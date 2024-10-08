import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  final _audioHandler = GetitUtil.audioHandler;
  late ConcatenatingAudioSource _playlist;

  // Listeners: Updates going to the UI
  final currentPlayingNotifier = ValueNotifier<MediaItem?>(null);
  final currentPlayingIndexNotifier = ValueNotifier<int?>(null);

  final playlistNotifier = ValueNotifier<List<IndexedAudioSource>>([]);
  final playlistTitlesNotifier = ValueNotifier<List<String>>([]);

  final progressNotifier = ProgressNotifier();
  final progressBarValueNotifier = ValueNotifier<double>(0);

  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);

  // Events: Calls coming from the UI
  void init() async {
    // await _loadPlaylist();
    // _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    // _listenToBufferedPosition();
    // _listenToTotalDuration();
    _listenToChangesInSong();
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();
  void seek(Duration position) => _audioHandler.seek(position);
  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  // void repeat() {}
  // void shuffle() {}
  // void add() {}
  // void remove() {}
  Future<void> dispose() async {
    await AudioPlayer.clearAssetCache();
    _audioHandler.audioPlayer.dispose(); 
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        // playButtonNotifier.value = ButtonState.loading;
        // playingStateNotifier.value = PlayingState.loading;
      } else if (!isPlaying) {
        // playButtonNotifier.value = ButtonState.paused;
        // playingStateNotifier.value = PlayingState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        // playButtonNotifier.value = ButtonState.playing;
        // playingStateNotifier.value = PlayingState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((Duration position) {
      Duration? duration = _audioHandler.mediaItem.value?.duration;
      if (duration == null) return;

      double val = position.inMilliseconds / duration.inMilliseconds;
      if (val <= 1) {
        GetitUtil.pageManager.progressBarValueNotifier.value = val;
      }
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentPlayingNotifier.value = mediaItem;

      _updateSkipButtons();

      // listen to total duration
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        // buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  // button controls
  void onPlayPauseButtonPressed() {
    _audioHandler.play();
  }

  void onPreviousSongButtonPressed() {
    _audioHandler.seekToPrevious();
  }

  void onNextSongButtonPressed() {
    _audioHandler.seekToNext();
  }

  Future<void> onShuffleButtonPressed() async {
    final enable = _audioHandler.playbackState.value.shuffleMode ==
        AudioServiceShuffleMode.none;
    if (enable) {
      await _audioHandler.shuffle();
      await _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      await _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }

    shuffleModeNotifier.value = enable;
  }

  void removeSong() {
    final index = _playlist.length - 1;
    if (index < 0) return;
    _playlist.removeAt(index);
  }
}

enum RepeatState { off, all, one }

class RepeatButtonNotifier extends ValueNotifier<RepeatState> {
  RepeatButtonNotifier() : super(_initialValue);
  static const _initialValue = RepeatState.off;

  void nextState() {
    final next = (value.index + 1) % RepeatState.values.length;
    value = RepeatState.values[next];
  }
}

class PlayButtonNotifier extends ValueNotifier<ButtonState> {
  PlayButtonNotifier() : super(_initialValue);
  static const _initialValue = ButtonState.paused;
}

enum ButtonState {
  paused,
  playing,
  loading,
}

class ProgressNotifier extends ValueNotifier<ProgressBarState> {
  ProgressNotifier() : super(_initialValue);
  static final _initialValue = ProgressBarState(
    current: Duration.zero,
    total: Duration.zero,
  );
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.total,
  }) : percent = total.inMilliseconds > 0
            ? current.inMilliseconds / total.inMilliseconds
            : 0;
  final Duration current;
  final Duration total;
  final double percent;
}
