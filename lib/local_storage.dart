import 'dart:io';
import 'package:dreamer_app/project.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    String rootDir = "${directory.path}/projects";
    bool directoryExists = await Directory(rootDir).exists();
    if (!directoryExists) {
      Directory dir = await Directory(rootDir).create();
      return dir.path;
    } else {
      return rootDir;
    }
  }

  Future<String> getProjectRootDirectory(String projectName) async {
    final path = await _localPath;
    return "$path/$projectName";
  }

  Future<File> getlocalFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<String> initProject(String projectName) async {
    try {
      String projectRoot = await getProjectRootDirectory(projectName);
      Directory dir = await Directory(projectRoot).create();

      File file = await File("${dir.path}/lyrics.txt").create();
      print('created lyrics file');
      print(file);
    } catch (e) {
      print('error when creating project');
      print(e);
    }

    return projectName;
  }

  Future<File> getLyricsFile(String projectName) async {
    String rootDir = await getProjectRootDirectory(projectName);
    File file = File("$rootDir/lyrics.txt");
    bool fileExists = file.existsSync();
    if (!fileExists) {
      file.createSync();
    }
    return file;
  }

  Future<String> getLyrics(String projectName) async {
    try {
      File file = await getLyricsFile(projectName);
      return file.readAsStringSync();
    } catch (e) {
      print('error getting lyrics');
      print(e);
    }

    return "Error getting lyrics";
  }

  Future<File> writeLyricsToFile(String projectName, String lyrics) async {
    File file = await getLyricsFile(projectName);

    // Write the file
    return file.writeAsString(lyrics);
  }

  Future<List<Project>> readProjects() async {
    try {
      List<Project> list = [];
      Directory dir = Directory(await _localPath);
      bool dirExists = await dir.exists();

      if (dirExists) {
        for (FileSystemEntity entity in dir.listSync()) {
          List<String> strList = entity.path.split("/");
          String projectName = strList[strList.length - 1];
          list.add(Project(name: projectName));
        }
      }

      return list;
    } catch (e) {
      print(e);
      throw Exception("Error getting projects");
    }
  }

  // readProject()
  // saveProject()
}
