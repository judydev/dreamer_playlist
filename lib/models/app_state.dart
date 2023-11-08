import 'package:dreamer_playlist/helpers/service_locator.dart';

class AppStates {
  String? currentTab;
  String? currentPlaying;
  String? currentPlaylistId;
  String? lastPlayed;
  String language = 'EN';
  bool darkMode = false;

  @override
  String toString() {
    return "AppStates{currentTab: $currentTab, currentPlaying: $currentPlaying, currentPlaylistId: $currentPlaylistId";
  }
}

class AppState {
  AppStateKey key;
  String value;

  AppState({required this.key, required this.value});

  Map<String, dynamic> toMap() {
    return {
      key.toString(): value,
    };
  }

  @override
  String toString() {
    return '{$key: $value}';
  }
}

enum AppStateKey {
  currentTab,
  currentPlaying,
  currentPlaylistId,
  lastPlayed,
  language,
  darkMode
}

const menuTabs = ['Library', 'Playlists', 'Favorites', 'Preferences'];
bool isFavoriteTab() {
  return GetitUtil.appStates.currentTab == menuTabs[2];
}

bool isPlaylistsTab() {
  return GetitUtil.appStates.currentTab == menuTabs[1];
}
