import 'dart:convert';
import 'dart:io';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/project_view.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StorageProvider extends ChangeNotifier {}

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

  Future<Project> initProject(Project project) async {
    try {
      String projectRoot = await getProjectRootDirectory(project.name);
      Directory dir = await Directory(projectRoot).create();

      File lyricsFile = await File("${dir.path}/lyrics.txt").create();
      lyricsFile.writeAsStringSync("");
      
      File timestampsFile = await File("${dir.path}/timestamps.txt").create();
      timestampsFile.writeAsStringSync("");

      File metadataFile = await File("${dir.path}/metadata.txt").create();
      Map<String, dynamic> metadata = Map.of({});
      metadata["name"] = project.name;
      metadata["description"] = project.description;
      metadata["created"] = DateTime.now().toString();
      metadata["lastModified"] = DateTime.now().toString();
      metadata["sectionNumber"] = 1;

      project.metadata = metadata;

      String metadataStr = jsonEncode(metadata);
      metadataFile.writeAsStringSync(metadataStr);
    } catch (e) {
      print('error when creating project');
      print(e);
    }

    return project;
  }

  Future<Project> editProject(Project project, String oldName) async {
    String projectRoot = await getProjectRootDirectory(project.name);
    Directory dir = Directory(projectRoot);
    if (oldName != project.name) {
      // rename project
      String oldProjectRoot = await getProjectRootDirectory(oldName);
      Directory oldDir = Directory(oldProjectRoot);
      dir = await oldDir.rename(projectRoot);
    }

    try {
      File metadataFile = File("${dir.path}/metadata.txt");
      writeMetadataFile(metadataFile, "description", project.description!);
    } catch (e) {
      print("error when editing project");
      print(e);
    }

    return project;
  }

  void writeMetadataFile(
      File metadataFile, String propertyName, String propertyValue) {
    try {
      String jsonStr = metadataFile.readAsStringSync();
      Map<String, dynamic> json =
          jsonStr.isEmpty ? Map.of({}) : jsonDecode(jsonStr);
      json[propertyName] = propertyValue;
      String newJsonStr = jsonEncode(json);
      metadataFile.writeAsStringSync(newJsonStr);
    } catch (e) {
      print("error when writing to metadata file");
      print(e);
    }
  }

  Future<void> deleteProject(String projectName) async {
    try {
      String projectRoot = await getProjectRootDirectory(projectName); 
      await Directory(projectRoot).delete(recursive: true);
    } catch (e) {
      print('error when deleting project');
      print(e);
    }
  }

  Future<File> getFileByName(String projectName, String fileName) async {
    // TODO: replace projectName with uuid
    String rootDir = await getProjectRootDirectory(projectName);
    File file = File("$rootDir/$fileName");
    bool fileExists = file.existsSync();
    if (!fileExists) {
      try {
        file.createSync();
      } catch (e) {
        print('error creating file');
        print(e);
      }
    }
    return file;
  }

  Future<String> getLyrics(String projectName) async {
    // TODO: replace projectName with uuid
    try {
      File file = await getFileByName(projectName, "lyrics.txt");
      return file.readAsStringSync();
    } catch (e) {
      print('error getting lyrics');
      print(e);
    }

    return "Error getting lyrics";
  }

  Future<File> writeLyricsToFile(String projectName, String lyrics) async {
    File file = await getFileByName(projectName, "lyrics.txt");

    // Write the file
    file.writeAsStringSync(lyrics);
    return file;
  }

  Future<File> writeToFile(String projectName, String contents) async {
    File file = await getFileByName(projectName, "metadata.txt");
    file.writeAsStringSync(contents);
    return file;
  }

  Future<File> writeSectionNumberToFile(
      String projectName, int sectionNumber) async {
    String rootDir = await getProjectRootDirectory(projectName);
    File file = File("$rootDir/metadata.txt");
    bool fileExists = file.existsSync();
    if (!fileExists) {
      try {
        file.createSync();
      } catch (e) {
        print('error creating file');
        print(e);
      }
    }

    String str = file.readAsStringSync();
    Map<String, dynamic> metadata = jsonDecode(str);
    metadata["sectionNumber"] = sectionNumber;
    String newMetadata = jsonEncode(metadata);
    file.writeAsStringSync(newMetadata);

    return file;
  }

  Future<List<Project>> readProjects() async {
    try {
      List<Project> list = [];
      Directory dir = Directory(await _localPath);
      bool dirExists = await dir.exists();

      if (dirExists) {
        for (FileSystemEntity entity in dir.listSync()) {
          List<String> strList = entity.path.split("/");
          String name = strList[strList.length - 1];
          list.add(Project(name: name)); // TODO: replace name with uuid
        }
      }

      return list;
    } catch (e) {
      print(e);
      throw Exception("Error getting projects");
    }
  }

  Future<Project> readProject(Project project) async {
    try {
      final path = await _localPath;
      // TODO: replace projectName with uuid
      String prefix = "$path/${project.name}";
      File timestampsFile = File("$prefix/timestamps.txt");
      File lyricsFile = File("$prefix/lyrics.txt");
      File metadataFile = File("$prefix/metadata.txt");

      List<String> timestampsList = timestampsFile.readAsLinesSync();
      List<String> lyricsList = lyricsFile.readAsStringSync().split(delimiter);
      String jsonStr = metadataFile.readAsStringSync();

      project.timestampList = timestampsList.isEmpty ? [""] : timestampsList;
      project.lyricsList = lyricsList.isEmpty ? [""] : lyricsList;
      Map<String, dynamic> json = jsonDecode(jsonStr);
      project.metadata?["name"] = json["name"];
      project.metadata?["description"] = json["description"];
      project.metadata?["sectionNumber"] = json["sectionNumber"];
      project.metadata?["lastModified"] = json["lastModified"];

      return project;
    } catch (e) {
      print(e);
      throw Exception("Error getting project ${project.name}");
    }
  }
}
