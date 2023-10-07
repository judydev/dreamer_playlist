import 'package:dreamer_app/helper.dart';
import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO: add viewing option on top menu bar to switch between grid and list view
class ProjectListView extends StatelessWidget {
  final Project project;
  ProjectListView(this.project);

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);

    return (ListTile(
      style: ListTileStyle.list,
      hoverColor: Colors.amberAccent,
      leading: Icon(Icons.library_music),
      title: Text(project.name),
      subtitle: Text('SubTitle'),
      onTap: () {
        stateProvider.currentProject = project;
      },
      onLongPress: () {
        // delete project
        showAlertDialogPopup(context, "Warning",
            Text("Are you sure you want to delete this project?"), [
          displayTextButton(context, "Yes", callback: () async {
            await LocalStorage().deleteProject(project.name);
            stateProvider.projects.remove(project);
          }),
          displayTextButton(context, "No")
        ]);
      },
    ));
  }
}
