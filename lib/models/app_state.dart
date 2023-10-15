class AppState {
  String key;
  String value;

  AppState({required this.key, required this.value});

  Map<String, dynamic> toMap() {
    return {
      key: value,
    };
  }

  @override
  String toString() {
    return 'AppState{$key: $value}';
  }
}
