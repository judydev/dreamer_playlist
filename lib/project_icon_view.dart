import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void _selectFile() {
  FilePicker.platform.pickFiles().then((selectedFile) => {
        print(selectedFile),
      });
}

class ProjectIconView extends StatelessWidget {
  ProjectIconView(this.title, this.callback);

  final String title;
  final Function? callback;

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        FloatingActionButton(
          onPressed: () => {callback!()},
          // tooltip: 'New',
          child: const Icon(Icons.add),
        ),
        Text(title),
        // Text(lastModifiedDateTime)
      ],
    ));
  }
}

getNewProjectIcon(String songName, setCurrentProjectCallBack) {
  return (Column(
    children: [
      FloatingActionButton(
        onPressed: setCurrentProjectCallBack,
        tooltip: 'New',
        child: const Icon(Icons.add),
      ),
      Text(songName),
      // Text(lastModifiedDateTime)
    ],
  ));
}

addAudioIcon() {
  return (Column(
    children: [
      FloatingActionButton(
          onPressed: _selectFile,
          tooltip: 'Add audio',
          child: const Icon(Icons.add)),
      Text('Import')
    ],
  ));
}

getProjectIcon(String songName) {
  return (Column(
    children: [
      FloatingActionButton(
        onPressed: () => {},
        // tooltip: songName,
        child: const Icon(Icons.audio_file),
      ),
      Text(songName),
      // Text(lastModifiedDateTime)
    ],
  ));
}
