import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/helpers/audio_handler.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

final getIt = GetIt.instance;

class GetitUtil {
  static bool registered = false;
  static initRegistration() async {
    if (registered) {
      print('Error: already registered');
      return;
    }

    getIt.registerSingleton(AppStates());

    List<Song> orderedSongList = [];
    getIt.registerSingleton(orderedSongList);

    MyAudioHandler audioHandler = await _initAudioService();
    getIt.registerSingleton(audioHandler);

    registered = true;
  }

  static _initAudioService() async {
    return await AudioService.init(
        builder: () => MyAudioHandler(), config: const AudioServiceConfig());
  }

  static AppStates appStates = getIt.get<AppStates>();
  static MyAudioHandler audioHandler = getIt.get<MyAudioHandler>();
  static List<Song> orderedSongList = getIt.get<List<Song>>();

  // debugging functions
  // ignore: non_constant_identifier_names
  static void print_AudioPlayer_AudioSource_Sequence(
      List<IndexedAudioSource> sequence) {
    print('audioPlayer.audioSource.sequence');
    List res = sequence.map((ias) => ias.tag).toList();
    print(res);
  }
}
