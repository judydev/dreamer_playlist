import 'package:dreamer_playlist/components/bottom_menu_bar_view.dart';
import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/playlist_view.dart';
import 'package:dreamer_playlist/components/playlists_view.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:dreamer_playlist/providers/playlist_data_provider.dart';
import 'package:dreamer_playlist/providers/playlist_song_data_provider.dart';
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
      ChangeNotifierProvider<PlaylistDataProvider>(
        create: (context) => PlaylistDataProvider(),
      ),
      ChangeNotifierProvider<PlaylistSongDataProvider>(
        create: (context) => PlaylistSongDataProvider(),
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
  late Future<String?> _getCurrentPlaylistAppState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    appStateDataProvider = Provider.of<AppStateDataProvider>(context);
    _getCurrentPlaylistAppState = appStateDataProvider.getLastPlayedAppState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomMenuBarView(),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: FutureBuilderWrapper(_getCurrentPlaylistAppState,
                (context, snapshot) {
          String? currentPlaylistId = snapshot.data;
          if (currentPlaylistId != null) {
            return FutureBuilderWrapper(
                Provider.of<PlaylistDataProvider>(context, listen: false)
                    .getPlaylistById(currentPlaylistId), (context, snapshot) {
              Playlist playlist = snapshot.data;
              return PlaylistView(playlist: playlist);
            });
          } else {
            return PlaylistsView();
          }
        })));
  }
}
