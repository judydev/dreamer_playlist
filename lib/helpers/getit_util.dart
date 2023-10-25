import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
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

    getIt.registerSingleton(currentlyPlayingNotifier);

    List<Song> orderedSongList = [];
    getIt.registerSingleton(orderedSongList);

    ConcatenatingAudioSource queue =
        ConcatenatingAudioSource(children: const []);
    getIt.registerSingleton(queue);

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
      print('playerState.listen: state.playing');
      print(state.playing);
      print(state.processingState);

      switch (state.processingState) {
        case ProcessingState.completed:
          print('music stops, refresh player-------------------');
          pauseStateNotifier.value = PauseState.paused;
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

    return ap;
  }

  static AppStates appStates = getIt.get<AppStates>();

  static AudioPlayer audioPlayer = getIt.get<AudioPlayer>();

  static ConcatenatingAudioSource queue =
      getIt.get<ConcatenatingAudioSource>();

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
    print('audioPlayer.audioSource.sequence');
    for (IndexedAudioSource ias in sequence) {
      print(ias.tag);
    }
  }
}
