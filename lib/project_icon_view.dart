import 'package:flutter/material.dart';

class ProjectIconView extends StatelessWidget {
  final String title;
  final Function? callback;
  // final bool isNew;

  ProjectIconView(this.title, this.callback);

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        FloatingActionButton(
          onPressed: () => {callback!()},
            child: Icon(Icons.add)
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

getProjectIcon(String songName) {
  return (Column(
    children: [
      FloatingActionButton(
        onPressed: () => {},
        child: const Icon(Icons.audio_file),
      ),
      Text(songName),
      // Text(lastModifiedDateTime)
    ],
  ));
}
