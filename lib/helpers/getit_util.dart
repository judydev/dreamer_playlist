import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
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

    registered = true;
  }

  static AudioPlayer _initAudioPlayer() {
    AudioPlayer ap = AudioPlayer();

    ap.positionStream.listen((position) {
      if (ap.duration != null) {
        progressBarValueNotifier.value =
            position.inMilliseconds / ap.duration!.inMilliseconds;
      }
    });

    ap.shuffleModeEnabledStream.listen(
      (event) {
        updateShuffleModeNotifier();
      },
    );

    ap.shuffleIndicesStream.listen((event) {
      updateQueueIndicesNotifier();
    });

    // update current index, refreshes player display value
    ap.currentIndexStream.listen((currentIndex) {
      currentlyPlayingNotifier.value =
          currentIndex != null && ap.sequence != null
              ? ap.sequence![currentIndex].tag
              : null;
    });

    ap.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.completed:
          print('music stops, refresh player-------------------');

          // reset playlist queue after player stops
          audioPlayer.setAudioSource(GetitUtil.queue);
          audioPlayer.pause();
          pauseStateNotifier.value = PauseState.paused;
          currentlyPlayingNotifier.value = null;
          updateQueueIndicesNotifier();
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
        ...songs.map((song) => AudioSource.file(song.path!, tag: song)),
      ],
    );
  }

  static void addSongToQueue(Song song) {
    print('addSongToQ');
    print(queue.children);
    AudioSource added = AudioSource.file(song.path!, tag: song);
    queue.children.add(added);
    print(queue.children);
    if (audioPlayer.audioSource == null) {
      setQueueFromSonglist([song]);
    }

    audioPlayer.setAudioSource(queue);
    updateQueueIndicesNotifier();
    print('effectiveIndic');
    print(audioPlayer.effectiveIndices);
  }

  // debugging functions
  // ignore: non_constant_identifier_names
  static void print_AudioPlayer_AudioSource_Sequence(
      List<IndexedAudioSource> sequence) {
    print('audioPlayer.audioSource.sequence');
    List res = sequence.map((ias) => ias.tag).toList();
    print(res);
  }

  // ignore: non_constant_identifier_names
  static void print_Songlist_from_Indices(List<int> indices) {
    List res = indices.map((i) => audioPlayer.sequence?[i].tag.name).toList();
    print('indices: $indices');
    print('songlist from indices: $res');
  }
}
