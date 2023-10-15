import 'package:uuid/uuid.dart';

class Lyrics {
  late String? id = Uuid().v4();
  late String? value;

  Lyrics({this.id, this.value});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
    };
  }
}
