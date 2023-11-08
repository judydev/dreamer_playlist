import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:just_audio/just_audio.dart';

Future<MyAudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
        // androidNotificationChannelId: 'com.mycompany.myapp.audio',
        // androidNotificationChannelName: 'Audio Service Demo',
        // androidNotificationOngoing: true,
        // androidStopForegroundOnPause: true,
        ),
  );
}

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
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();

    // _listenForPositionChanges();
    _listenForSequenceChanges();
    _listenForPlayerStateChanges();
    _listenForShuffleModeChanges();
    // _listenForLoopModeChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _audioPlayer.setAudioSource(_songQueue);
    } catch (e) {
      print('Error loading empty playlist $e');
    }
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

          int firstIndex = 0;
          if (_audioPlayer.shuffleModeEnabled) {
            firstIndex = _audioPlayer.effectiveIndices![0];
          }
          await _audioPlayer.pause();
          await _audioPlayer.seek(Duration.zero, index: firstIndex);
          break;
        default:
          return;
      }
    });
  }

  void _listenForShuffleModeChanges() {
    _audioPlayer.shuffleModeEnabledStream.listen(((shuffleModeEnabled) {
      shuffleModeNotifier.value = shuffleModeEnabled;
    }));

    _audioPlayer.shuffleIndicesStream
        .listen((event) {}); // this stream is always changing
  }

  // void _listenForLoopModeChanges() {
  //   _audioPlayer.loopModeStream.listen(
  //     (event) {
  //       print('loopmode changed to $event');
  //     },
  //   );
  // }

  // @override
  // Future<void> click([MediaButton button = MediaButton.media]) {
  //   print('clicked');
  //   return super.click();
  // }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() => _audioPlayer.stop();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> skipToPrevious() => _audioPlayer.seekToPrevious();

  @override
  Future<void> skipToNext() => _audioPlayer.seekToNext();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (isEmptyQueue()) return;
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
    await super.skipToQueueItem(index);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await _audioPlayer
        .setShuffleModeEnabled(shuffleMode == AudioServiceShuffleMode.all);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    LoopMode loopMode = LoopMode.off;
    switch (repeatMode) {
      case AudioServiceRepeatMode.all:
        loopMode = LoopMode.all;
        break;
      case AudioServiceRepeatMode.one:
        loopMode = LoopMode.one;
        break;
      default:
        loopMode = LoopMode.off;
    }

    await _audioPlayer.setLoopMode(loopMode);
    loopModeNotifier.value = loopMode;
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

  // @override
  // Future<void> addQueueItems(List<MediaItem> mediaItems) async {
  //   // manage Just Audio
  //   final audioSource = mediaItems.map(_createAudioSource);
  //   _playlist.addAll(audioSource.toList());

  //   // notify system
  //   final newQueue = queue.value..addAll(mediaItems);
  // queue.add(newQueue); // notify AudioHandler about changes to the playlist
  // }

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

  // UriAudioSource _createAudioSourceFromUrl(MediaItem mediaItem) {
  //   return AudioSource.uri(
  //     Uri.parse(mediaItem.extras!['url'] as String),
  //     tag: mediaItem,
  //   );
  // }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (_songQueue.length > index) {
      _songQueue.removeAt(index);

      final newQueue = queue.value..removeAt(index);
      queue.add(newQueue);

      updateQueueIndicesNotifier();
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _audioPlayer.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _audioPlayer.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: playing,
        updatePosition: _audioPlayer.position,
        // bufferedPosition: _audioPlayer.bufferedPosition,
        shuffleMode: _audioPlayer.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: loopModeToRepeatMode(_audioPlayer.loopMode),
        speed: _audioPlayer.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  AudioServiceRepeatMode loopModeToRepeatMode(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.off:
      default:
        return AudioServiceRepeatMode.none;
    }
  }

  void _listenForDurationChanges() {
    _audioPlayer.durationStream.listen((duration) {
      final index = _audioPlayer.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _audioPlayer.currentIndexStream.listen((index) {
      // when clicking on songTile
      final playlist = queue.value; // ordered list
      if (index == null || playlist.isEmpty) return;

      mediaItem.add(playlist[index]);

      // currentIndexNotifier.value = index;
      // final seq = _audioPlayer.sequenceState?.effectiveSequence;
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

      // GetitUtil.pageManager.playlistNotifier.value = sequence;
      updateQueueIndicesNotifier();
    });

    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      // TODO: update current song title
      // final currentItem = sequenceState.currentSource;
      // final title = currentItem?.tag as String?;
      // currentSongTitleNotifier.value = title ?? '';
      // print('sequenceState.currentindex = ${sequenceState.currentIndex}');

      // TODO: update playlist
      // final playlist = sequenceState.effectiveSequence;
      // print('sequenceState playlist change');
      // print(playlist
      //     .map(
      //       (e) => (e.tag as MediaItem).title,
      //     )
      //     .toList());
      // final titles = playlist.map((item) => item.tag as String).toList();
      // playlistNotifier.value = titles;
      // GetitUtil.pageManager.playlistNotifier.value = playlist;

      // TODO: update shuffle mode, handled in _listenForShuffleModeChanges()
      // print('sequenceState.shuffleMode = ${sequenceState.shuffleModeEnabled}');
      // shuffleModeNotifier.value = sequenceState.shuffleModeEnabled;
      // GetitUtil.pageManager.isShuffleModeEnabledNotifier.value =
      //     sequenceState.shuffleModeEnabled;

      // TODO: update previous and next buttons
      // if (playlist.isEmpty || currentItem == null) {
      //   GetitUtil.pageManager.isFirstSongNotifier.value = true;
      //   GetitUtil.pageManager.isLastSongNotifier.value = true;
      // } else {
      //   GetitUtil.pageManager.isFirstSongNotifier.value =
      //       playlist.first == currentItem;
      //   GetitUtil.pageManager.isLastSongNotifier.value =
      //       playlist.last == currentItem;
      // }
    });
  }
}
