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
  currentPlaylistId,
  lastPlayed,
  language,
  darkMode
}

enum CurrentTab { library, playlists, favorites, preferences }
