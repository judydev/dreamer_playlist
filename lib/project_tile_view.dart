import 'package:dreamer_app/project.dart';
import 'package:flutter/material.dart';

class ProjectTileView extends StatelessWidget {
  final Project project;
  final Function openProjectCallback;

  ProjectTileView(this.project, this.openProjectCallback);

  @override
  Widget build(BuildContext context) {
    return (ListTile(
      style: ListTileStyle.list,
      hoverColor: Colors.amberAccent,
      leading: Icon(Icons.library_music),
      title: Text(project.name),
      subtitle: Text('SubTitle'),
      onTap: () {
        openProjectCallback(project);
      },
    ));
  }
}
