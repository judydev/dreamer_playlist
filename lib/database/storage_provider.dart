import 'dart:io';

import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StorageProvider extends ChangeNotifier {
  Future<Directory> get _localDir async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<String> getLocalStoragePath() async {
    final dir = await _localDir;
    return dir.path;
  }

  File getAudioFile(String path) {
    File file = File(path);
    if (!file.existsSync()) {
      throw Exception("Cannot find file");
    }
    return file;
  }

  static String getFilenameFromPlatformFile(String fullname, String extension) {
    int index = fullname.lastIndexOf(extension);
    return fullname.substring(0, index - 1);
  }

  Future<File> addSongFileToLocalStorage(PlatformFile selectedFile) async {
    String? extension = selectedFile.extension;
    String filename =
        getFilenameFromPlatformFile(selectedFile.name, extension!);
    
    // copy song to local storage
    final path = await getLocalStoragePath();
    String newPathWithoutFileExtension = '$path/$filename';
    while (File("$newPathWithoutFileExtension.$extension").existsSync()) {
      // append " copy" at the end of the file name when there is a duplicate
      newPathWithoutFileExtension = "$newPathWithoutFileExtension copy";
    }

    return await File(selectedFile.path!)
        .copy("$newPathWithoutFileExtension.$extension");
  }

  void deleteSongFileFromLocalStorage(String path) {
    File file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<String> getRelativePath(String path) async {
    final dir = (await getApplicationDocumentsDirectory()).path;
    final relativePath = path.replaceAll(dir, '');
    return relativePath;
  }
}
