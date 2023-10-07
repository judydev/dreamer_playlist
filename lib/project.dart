class Project {
  String name = "";
  String? desription = "";
  bool isEmpty;
  bool isNew;
  List<String>? audioFiles = [];
  List<String>? recordings = [];
  String? lyrics = "";

  Project(
      {required this.name,
      this.desription,
      this.audioFiles,
      this.recordings,
      this.lyrics,
      this.isEmpty = true,
      this.isNew = true});
}
