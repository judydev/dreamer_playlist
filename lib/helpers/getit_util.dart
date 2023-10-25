import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

final getIt = GetIt.instance;

class GetitUtil {
  static bool registered = false;
  static initRegistration() {
    if (registered) {
      print('Error: already registered');
      return;
    }

    getIt.registerSingleton(AppStates());

    AudioPlayer audioPlayer = _initAudioPlayer();
    getIt.registerSingleton(audioPlayer);

    ValueNotifier<Song?> currentlyPlayingNotifier = ValueNotifier(null);
    getIt.registerSingleton(currentlyPlayingNotifier);

    List<Song> orderedSongList = [];
    getIt.registerSingleton(orderedSongList);

    ConcatenatingAudioSource queue =
        ConcatenatingAudioSource(children: const []);
    getIt.registerSingleton(queue);

    ValueNotifier<List<int>?> effectiveIndicesNotifier = ValueNotifier(null);
    getIt.registerSingleton(effectiveIndicesNotifier);

    registered = true;
  }

  static AudioPlayer _initAudioPlayer() {
    AudioPlayer ap = AudioPlayer();
    // audioPlayer.pause()
    ap.sequenceStream.listen((event) {
      // print('sequenceStream listen');
    });

    // update current index, refreshes player display value
    ap.currentIndexStream.listen((currentIndex) {
      print('currentIndex = $currentIndex');
      currentlyPlayingNotifier.value =
          currentIndex != null ? orderedSongList[currentIndex] : null;
    });

    ap.playerStateStream.listen((state) {
      // print('playerStateStream listen');
      // print(state);
      switch (state.processingState) {
        // case ProcessingState.ready:
        //   break;
        case ProcessingState.completed:
          // print('music stops, refresh player');
          // print(audioPlayer.)
          audioPlayer.stop();
          break;
        default:
          return;
      }
    });

    // --- when calling player.play() or player.pause(), this state changes true/false ---
    ap.playingStream.listen((event) {
      // print('playingStream.listen');
      // print(event);
    });

    // ap.durationStream.listen(
    //   (event) {
    //     print('durationStream.listen');
    //     print(event);
    //   },
    // );

    // ap.positionStream.listen((event) {
    //   print('positionStream.listen');
    //   print(event);
    // });

    // ap.playbackEventStream.listen((event) {
    //   print('playbackEventStream.listen');
    //   print(event);
    // });

    return ap;
  }

  static AppStates appStates = getIt.get<AppStates>();

  static AudioPlayer audioPlayer = getIt.get<AudioPlayer>();
  static ValueNotifier<Song?> currentlyPlayingNotifier =
      getIt.get<ValueNotifier<Song?>>();

  static ConcatenatingAudioSource queue =
      getIt.get<ConcatenatingAudioSource>();

  // static ValueNotifier<ConcatenatingAudioSource> queueNotifier =
  //     getIt.get<ValueNotifier<ConcatenatingAudioSource>>();
  static ValueNotifier<List<int>?> effectiveIndicesNotifier =
      getIt.get<ValueNotifier<List<int>?>>();

  static List<Song> orderedSongList = getIt.get<List<Song>>();

  static void setQueueFromSonglist(List<Song> songs) {
    queue = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: [
        ...songs.map((song) => AudioSource.file(song.path!, tag: song.name)),
      ],
    );
  }

  static List<Song> buildSonglistFromIndicies(List<Song> songs) {
    return songs;
  }

  // debugging functions
  // ignore: non_constant_identifier_names
  static void print_AudioPlayer_AudioSource_Sequence(sequence) {
    // audioPlayer.audioSource!.sequence
    print('audioPlayer.audioSource.sequence');
    for (IndexedAudioSource ias in sequence) {
      print(ias.tag);
    }
  }

  // static String? currentTab = appStates.currentTab;
}
