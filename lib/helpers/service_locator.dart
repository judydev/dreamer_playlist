import 'package:dreamer_playlist/helpers/audio_handler.dart';
import 'package:dreamer_playlist/helpers/page_manager.dart';
import 'package:dreamer_playlist/helpers/permission_service.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  AppStates appStates = AppStates();
  getIt.registerSingleton<AppStates>(appStates);

  getIt.registerSingleton<PermissionService>(PermissionHandler());

  final dir = await getApplicationDocumentsDirectory();
  appStates.appDocumentsDir = dir.path;

  getIt.registerSingleton<MyAudioHandler>(await initAudioService());
  getIt.registerSingleton<List<Song>>([]);
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}

class GetitUtil {
  static AppStates appStates = getIt<AppStates>();
  static String? appDocumentsDir = appStates.appDocumentsDir;
  static MyAudioHandler audioHandler = getIt<MyAudioHandler>();
  static List<Song> orderedSongList = getIt<List<Song>>();
  static PageManager pageManager = getIt<PageManager>();
}

// AppStates getItAppStates = getIt<AppStates>();
// MyAudioHandler getItAudioHandler = getIt<MyAudioHandler>();
// List<Song> getItOrderedSongList = getIt<List<Song>>();
// PageManager getItPageManager = getIt<PageManager>();
