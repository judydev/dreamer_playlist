import 'package:uuid/uuid.dart';

class Project {
  late String? id = Uuid().v4();
  late String name;
  late String? description;
  // final DateTime created;
  // DateTime lastModified;
  // bool archived = false;

  Project({
    this.id,
    required this.name,
    // this.created,
    // this.lastModified,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Project{id: $id, name: $name, description: $description}';
  }
}
