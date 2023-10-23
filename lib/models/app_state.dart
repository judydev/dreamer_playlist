class AppStates {
  String? currentTab;
  String? currentPlaying;
  String? currentPlaylistId;
  String? lastPlayed;
  String language = 'EN';
  bool darkMode = false;

  @override
  String toString() {
    return "AppStates{currentTab: $currentTab, currentPlaying: $currentPlaying, currentPlaylistId: $currentPlaylistId, lastPlayed: $lastPlayed";
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
    return 'AppState{$key: $value}';
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

AppStateKey getAppStateKeyFromString(String key) {
  switch (key) {
    case 'currentTab':
      return AppStateKey.currentTab;
    case 'currentPlaying':
      return AppStateKey.currentPlaying;
    case 'currentPlaylistId':
      return AppStateKey.currentPlaylistId;
    case 'lastPlayed':
      return AppStateKey.lastPlayed;
    case 'language':
      return AppStateKey.language;
    case 'darkMode':
      return AppStateKey.darkMode;
    default:
      throw Exception('Unknown key');
  }
}

const menuTabs = ['Library', 'Playlists', 'Favorites', 'Preferences'];
