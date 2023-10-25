import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/components/miniplayer/expandable_player.dart';
import 'package:dreamer_playlist/components/favorites_view.dart';
import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/library_view.dart';
import 'package:dreamer_playlist/components/playlist_view.dart';
import 'package:dreamer_playlist/components/playlists_view.dart';
import 'package:dreamer_playlist/components/preferences_view.dart';
import 'package:dreamer_playlist/database/data_util.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/database/database_util.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:dreamer_playlist/database/storage_provider.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseUtil.initDatabase();
  GetitUtil.initRegistration();
  await DataUtil.loadInitialData();

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
      ChangeNotifierProvider<StorageProvider>(
        create: (context) => StorageProvider(),
      ),
    ], child: const MyApp()),
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
      home: const MyHomePage(),
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
  late PlaylistDataProvider playlistDataProvider;
  int _selectedTabIndex = menuTabs.indexOf(GetitUtil.appStates.currentTab!);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    appStateDataProvider = Provider.of<AppStateDataProvider>(context);
    playlistDataProvider = Provider.of<PlaylistDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildTabView(context, _selectedTabIndex),
          ValueListenableBuilder(
            valueListenable: GetitUtil.currentlyPlayingNotifier,
            builder: (BuildContext context, Song? song, Widget? child) =>
                song != null ? ExpandablePlayer()
                    : SizedBox.shrink(),
          ),
        ],
      ),
      // bottomNavigationBar gets pushed down when player is in full screen mode
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: playerExpandProgress,
        builder: (BuildContext context, double height, Widget? child) {
          double playerMaxHeight = MediaQuery.of(context).size.height;
          final value = percentageFromValueInRange(
              min: playerMinHeight, max: playerMaxHeight, value: height);

          var opacity = 1 - value;
          if (opacity < 0) opacity = 0;
          if (opacity > 1) opacity = 1;

          return SizedBox(
            height:
                kBottomNavigationBarHeight - kBottomNavigationBarHeight * value,
            child: Transform.translate(
              offset: Offset(0.0, kBottomNavigationBarHeight * value * 0.5),
              child: Opacity(
                opacity: opacity,
                child: OverflowBox(
                  maxHeight: kBottomNavigationBarHeight,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Wrap(children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedTabIndex,
            selectedItemColor: Colors.red,
            onTap: (index) => setState(() {
              _selectedTabIndex = index;
              GetitUtil.appStates.currentTab = menuTabs[index];
              Provider.of<AppStateDataProvider>(context, listen: false)
                  .updateAppState(AppStateKey.currentTab, menuTabs[index]);
            }),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_outlined), label: 'Library'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.queue_music), label: 'Playlists'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Favorite'),
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.settings), label: 'Preferences'),
            ],
          ),
        ]),
      ),
    );
  }

  buildTabView(context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return LibraryView();
      case 1:
        return FutureBuilderWrapper(
            appStateDataProvider.getAppStateByKey(
                AppStateKey.currentPlaylistId), (context, snapshot) {
          String? currentPlaylistId = snapshot.data;
          if (currentPlaylistId != null) {
            return FutureBuilderWrapper(
                playlistDataProvider.getPlaylistById(currentPlaylistId),
                (context, snapshot) {
              Playlist playlist = snapshot.data;
              return PlaylistView(playlist: playlist);
            });
          } else {
            return PlaylistsView();
          }
        });
      case 2:
        return FavoritesView();
      case 3:
        return PreferencesView();
      default:
        return LibraryView();
    }
  }
}
