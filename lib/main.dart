import 'package:dreamer_playlist/components/bottom_menu_bar_view.dart';
import 'package:dreamer_playlist/components/favorites_view.dart';
import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/library_view.dart';
import 'package:dreamer_playlist/components/playlist_view.dart';
import 'package:dreamer_playlist/components/playlists_view.dart';
import 'package:dreamer_playlist/components/preferences_view.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:dreamer_playlist/providers/playlist_data_provider.dart';
import 'package:dreamer_playlist/providers/playlist_song_data_provider.dart';
import 'package:dreamer_playlist/providers/song_data_provider.dart';
import 'package:dreamer_playlist/providers/storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseUtil.initDatabase();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<AppStateDataProvider>(
        create: (context) => AppStateDataProvider(),
      ),
      ChangeNotifierProvider<SongDataProvider>(
        create: (context) => SongDataProvider(),
      ),      
      ChangeNotifierProvider<PlaylistDataProvider>(
        create: (context) => PlaylistDataProvider(),
      ),
      ChangeNotifierProvider<PlaylistSongDataProvider>(
        create: (context) => PlaylistSongDataProvider(),
      ),
      ChangeNotifierProvider<StorageProvider>(
        create: (context) => StorageProvider(),
      ),
    ], child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreamer Playlist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AppStateDataProvider appStateDataProvider;
  late Future<Map<String, dynamic>> _getAppStates;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    appStateDataProvider = Provider.of<AppStateDataProvider>(context);
    _getAppStates = appStateDataProvider.getAppStates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomMenuBarView(),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: FutureBuilderWrapper(_getAppStates,
                loadingText: "Loading app state...",
                (context, snapshot) {
          Map<String, dynamic> appStates = snapshot.data;
          String? currentTab = appStates[AppStateKey.currentTab.name];
          switch (currentTab) {
            case 'library':
              return LibraryView();
            case 'playlists':
              String? currentPlaylistId = appStates['currentPlaylistId'];
              if (currentPlaylistId != null) {
                return FutureBuilderWrapper(
                    Provider.of<PlaylistDataProvider>(context, listen: false)
                        .getPlaylistById(currentPlaylistId),
                    loadingText: "Loading current playlist...",
                    (context, snapshot) {
                  Playlist playlist = snapshot.data;
                  return PlaylistView(playlist: playlist);
                });
              } else {
                return PlaylistsView();
              }
            case 'favorites':
              return FavoritesView();
            case 'preferences':
              return PreferencesView();
            default:
              return LibraryView();
          }

        })));
  }
}
