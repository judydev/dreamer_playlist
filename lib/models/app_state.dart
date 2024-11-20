import 'package:dreamer_playlist/helpers/service_locator.dart';

class AppStates {
  String? currentTab;
  String? currentPlaying;
  String? currentPlaylistId;
  // TODO
  String? lastPlayed;
  String language = 'EN';

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
}

const menuTabs = ['Library', 'Playlists', 'Favorites', 'Settings'];
bool isFavoriteTab() {
  return GetitUtil.appStates.currentTab == menuTabs[2];
}

bool isPlaylistsTab() {
  return GetitUtil.appStates.currentTab == menuTabs[1];
}
