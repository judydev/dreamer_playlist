import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  // mix in default seek callback implementations

  final _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  final _songQueue = ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _audioPlayer.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _listenForCurrentSongIndexChanges();
    _listenForPositionChanges();
    _listenForSequenceChanges();
    _listenForPlayerStateChanges();
    _listenForShuffleModeChanges();
    _listenForLoopModeChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _audioPlayer.setAudioSource(_songQueue);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _listenForCurrentSongIndexChanges() {
    _audioPlayer.currentIndexStream.listen((index) {
      currentIndexNotifier.value = index;
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      // if (_audioPlayer.shuffleModeEnabled) {
      //   index = _audioPlayer.shuffleIndices![index];
      // }

      mediaItem.add(playlist[index]);
      print('currentIndexChange to $index -------------');
      print(_audioPlayer.effectiveIndices);
    });
  }

  void _listenForPositionChanges() {
    _audioPlayer.positionStream.listen((position) {
      if (_audioPlayer.duration != null && position != Duration.zero) {
        progressBarValueNotifier.value =
            position.inMilliseconds / _audioPlayer.duration!.inMilliseconds;
      }
    });
  }

  void _listenForSequenceChanges() {
    _audioPlayer.sequenceStream.listen((sequence) {
      print('sequence changed');
      print(sequence);
      if (sequence == null || sequence.isEmpty) {
        return;
      }

      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());

      updateQueueIndicesNotifier();
    });
  }

  void _listenForPlayerStateChanges() {
    _audioPlayer.playingStream.listen(
      (playing) {
        playingStateNotifier.value =
            playing ? PlayingState.playing : PlayingState.paused;
      },
    );

    _audioPlayer.playerStateStream.listen((state) async {
      switch (state.processingState) {
        case ProcessingState.completed:
          currentIndexNotifier.value = null;

          await _audioPlayer.pause();
          await _audioPlayer.seek(Duration.zero, index: 0);
          break;
        default:
          return;
      }
    });
  }

  void _listenForShuffleModeChanges() {
    _audioPlayer.shuffleModeEnabledStream.listen(((event) {
      updateShuffleModeNotifier();
    }));
  }

  void updateShuffleModeNotifier() {
    shuffleModeNotifier.value =
        _audioPlayer.shuffleModeEnabled ? ShuffleMode.on : ShuffleMode.off;
  }

  void _listenForLoopModeChanges() {
    _audioPlayer.loopModeStream.listen(
      (event) {
        print('loopmode changed to $event');
      },
    );
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    await super.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (isEmptyQueue()) return;
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
    await super.skipToQueueItem(index);
  }

  Future<void> shuffle() => _audioPlayer.shuffle();
  Future<void> seekToNext() => _audioPlayer.seekToNext();
  Future<void> seekToPrevious() => _audioPlayer.seekToPrevious();

  Future<void> resetQueueFromSonglist(List<Song> songs) async {
    _songQueue.clear();
    _songQueue.addAll(songs
        .map((song) => AudioSource.file(song.path!, tag: song.toMediaItem()))
        .toList());
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final audioSource = _createAudioSource(mediaItem);
    _songQueue.add(audioSource);

    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);

    updateQueueIndicesNotifier();
  }

  Future<void> addQueueItemAt(MediaItem mediaItem, int index) async {
    final audioSource = _createAudioSource(mediaItem);
    if (_songQueue.length > index) {
      index += 1;
    } else {
      index = _songQueue.length;
    }

    _songQueue.insert(index, audioSource);

    final newQueue = queue.value..insert(index, mediaItem);
    queue.add(newQueue);

    updateQueueIndicesNotifier();
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.file(mediaItem.extras!['path'], tag: mediaItem);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (_songQueue.length > index) {
      _songQueue.removeAt(index);

      final newQueue = queue.value..removeAt(index);
      queue.add(newQueue);

      updateQueueIndicesNotifier();
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
        controls: [
          MediaControl.rewind,
          if (_audioPlayer.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        // androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        // bufferedPosition: player.bufferedPosition
        speed: _audioPlayer.speed,
        queueIndex: event.currentIndex);
  }
}
