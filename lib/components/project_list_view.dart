import 'package:dreamer_app/helpers/helper.dart';
import 'package:dreamer_app/models/project.dart';
import 'package:flutter/material.dart';

// TODO: add viewing option on top menu bar to switch between grid and list view
class ProjectListView extends StatelessWidget {
  final Project project;
  ProjectListView(this.project);

  @override
  Widget build(BuildContext context) {
    return (ListTile(
      style: ListTileStyle.list,
      hoverColor: Colors.amberAccent,
      leading: Icon(Icons.library_music),
      title: Text(project.name),
      subtitle: Text('SubTitle'),
      onTap: () {
        // updateCurrentProject(); //TODO
      },
      onLongPress: () {
        // delete project
        showAlertDialogPopup(context, "Warning",
            Text("Are you sure you want to delete this project?"), [
          displayTextButton(context, "Yes", callback: () async {
            // deleteProject(project.id!); //TODO
          }),
          displayTextButton(context, "No")
        ]);
      },
    ));
  }
}
