class Project {
  // String uuid = ""; // TODO
  String name = "";
  String? description = "";
  List<String>? audioFiles = [];
  List<String>? recordings = [];
  List<String>? timestampList = [];
  List<String>? lyricsList = [""];
  
  Map<String, dynamic>? metadata;

  Project({
    // required this.uuid,
    required this.name,
    this.description,
    this.audioFiles,
    this.recordings,
    this.timestampList,
    this.lyricsList,
    this.metadata,
  });
}

// class Metadata {
//   int? sectionNumber = 1;

//   Metadata({
//     this.sectionNumber,
//   });
// }
