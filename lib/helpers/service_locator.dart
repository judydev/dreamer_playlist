import 'package:dreamer_playlist/helpers/audio_handler.dart';
import 'package:dreamer_playlist/helpers/page_manager.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());
  getIt.registerSingleton(AppStates());
  getIt.registerSingleton<MyAudioHandler>(await initAudioService());
  getIt.registerSingleton<List<Song>>([]);
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}

class GetitUtil {
  static AppStates appStates = getIt<AppStates>();
  static MyAudioHandler audioHandler = getIt<MyAudioHandler>();
  static List<Song> orderedSongList = getIt<List<Song>>();
  static PageManager pageManager = getIt<PageManager>();
}

// AppStates getItAppStates = getIt<AppStates>();
// MyAudioHandler getItAudioHandler = getIt<MyAudioHandler>();
// List<Song> getItOrderedSongList = getIt<List<Song>>();
// PageManager getItPageManager = getIt<PageManager>();
