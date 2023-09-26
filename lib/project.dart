class Project {
  bool isEmpty;
  bool isNew;
  List<String>? audioFiles = [];
  List<String>? recordings = [];
  String? lyrics = "";

  Project(
      {this.audioFiles,
      this.recordings,
      this.lyrics,
      this.isEmpty = true,
      this.isNew = true});
}
