import 'package:uuid/uuid.dart';

class ProjectSection {
  late String? id = Uuid().v4();
  late String projectId;
  late int sectionOrder;
  late String? audioFileId;
  late String? recordingFileId;
  late String? lyricsId;

  ProjectSection({
    this.id,
    required this.projectId,
    required this.sectionOrder,
    this.audioFileId,
    this.recordingFileId,
    this.lyricsId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'sectionOrder': sectionOrder,
      'audioFileId': audioFileId,
      'recordingFileId': recordingFileId,
      'lyricsId': lyricsId
    };
  }

  // @override
  // String toString() {
  //   return 'Project{id: $id, name: $name, description: $description}';
  // }
}
