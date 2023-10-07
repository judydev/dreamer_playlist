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

  Future<void> initProject(String projectName) async {
    try {
      String projectRoot = await getProjectRootDirectory(projectName);
      Directory dir = await Directory(projectRoot).create();

      File lyricsFile = await File("${dir.path}/lyrics.txt").create();
      File timestampsFile = await File("${dir.path}/timestamps.txt").create();
      print('created lyrics file');
      print(lyricsFile);
    } catch (e) {
      print('error when creating project');
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

  Future<File> getLyricsFile(String projectName) async {
    String rootDir = await getProjectRootDirectory(projectName);
    File file = File("$rootDir/lyrics.txt");
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

  Future<Project> readProject(Project project) async {
    try {
      final path = await _localPath;
      File timestampsFile = File("$path/${project.name}/timestamps.txt");
      File lyricsFile = File("$path/${project.name}/lyrics.txt");

      List<String> timestampsList = timestampsFile.readAsLinesSync();
      List<String> lyricsList = lyricsFile.readAsStringSync().split(delimiter);

      project.timestampList = timestampsList.isEmpty ? [""] : timestampsList;
      project.lyricsList = lyricsList.isEmpty ? [""] : lyricsList;

      return project;
    } catch (e) {
      print(e);
      throw Exception("Error getting project ${project.name}");
    }
  }

  // readProject()
  // saveProject()
}
