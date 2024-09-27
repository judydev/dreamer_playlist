import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/components/miniplayer/expandable_player.dart';
import 'package:dreamer_playlist/components/favorites_tab_view.dart';
import 'package:dreamer_playlist/components/library_tab_view.dart';
import 'package:dreamer_playlist/components/playlist_tab_view.dart';
import 'package:dreamer_playlist/components/playlists_tab_view.dart';
import 'package:dreamer_playlist/components/settings/settings_controller.dart';
import 'package:dreamer_playlist/components/settings/settings_service.dart';
import 'package:dreamer_playlist/components/settings_tab_view.dart';
import 'package:dreamer_playlist/database/data_util.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/database/database_util.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:dreamer_playlist/database/storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseUtil.initDatabase();
  await DataUtil.loadInitialData();
  
  await setupServiceLocator();

  final settingsController = SettingsController(SettingsService());
  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

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
    ], child: MyApp(settingsController: settingsController)),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({required this.settingsController});
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreamer Playlist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: settingsController.themeMode,
      home: MyHomePage(settingsController: settingsController),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.settingsController});
  final SettingsController settingsController;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SettingsController settingsController = widget.settingsController;

  late AppStateDataProvider appStateDataProvider;
  late PlaylistDataProvider playlistDataProvider;
  int _selectedTabIndex = GetitUtil.appStates.currentTab != null
      ? (menuTabs.contains(GetitUtil.appStates.currentTab!)
      ? menuTabs.indexOf(GetitUtil.appStates.currentTab!) : 0) : 0;

  @override
  void initState() {
    super.initState();
    GetitUtil.pageManager.init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    appStateDataProvider = Provider.of<AppStateDataProvider>(context);
    playlistDataProvider = Provider.of<PlaylistDataProvider>(context);
  }

  @override
  void dispose() {
    GetitUtil.pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
              // prevent list from being hidden behind miniplayer
              height: MediaQuery.sizeOf(context).height > 0
                  ? MediaQuery.sizeOf(context).height
                  : null,
              child: buildTabView(context, _selectedTabIndex)),
          ExpandablePlayer()
        ],
      ),
      // bottomNavigationBar gets pushed down when player is in full screen mode
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: playerExpandProgress,
        builder: (BuildContext context, double height, Widget? child) {
          double playerMaxHeight = MediaQuery.sizeOf(context).height;
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
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
              GetitUtil.appStates.currentTab = menuTabs[index];
              Provider.of<AppStateDataProvider>(context, listen: false)
                  .updateAppState(AppStateKey.currentTab, menuTabs[index]);
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_outlined), label: 'Library'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.queue_music), label: 'Playlists'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Favorites'),
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ]),
      ),
    );
  }

  buildTabView(context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return LibraryTabView();
      case 1:
        return FutureBuilderWrapper(
            appStateDataProvider.getAppStateByKey(
                AppStateKey.currentPlaylistId), (context, snapshot) {
          String? currentPlaylistId = snapshot.data;
          if (currentPlaylistId != null) {
            return FutureBuilderWrapper(
                playlistDataProvider.getPlaylistById(currentPlaylistId),
                (context, snapshot) {
              Playlist? playlist = snapshot.data;
              if (playlist == null) {
                debugPrint(
                    'Something wrong with currentPlaylistId: $currentPlaylistId');
                return PlaylistsTabView();
              }
              return PlaylistTabView(playlist: playlist);
            });
          } else {
            return PlaylistsTabView();
          }
        });
      case 2:
        return FavoritesTabView();
      case 3:
        return SettingsTabView(
          controller: settingsController,
        );
      default:
        return LibraryTabView();
    }
  }
}
