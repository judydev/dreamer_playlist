import 'package:dreamer_app/helper.dart';
import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/project_icon_view.dart';
import 'package:dreamer_app/project_tile_view.dart';
import 'package:dreamer_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// displays all existing projects
class ProjectsView extends StatefulWidget {
  ProjectsView();

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  
  createNewProjectCallBack() {
    String songName = "";
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Project"),
          content: displayTextInputField(context, "Song Name", (value) {
            setState(() {
              songName = value;
            });
          }),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () => {
                      LocalStorage().initProject(songName).then(
                        (value) {
                          Provider.of<StateProvider>(context, listen: false)
                                  .currentProject =
                              Project(name: songName, isNew: true);
                        },
                      )
                    })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);
    LocalStorage()
        .readProjects()
        .then((value) => {stateProvider.projects = value});

    return (Flex(direction: Axis.vertical, children: [
      ProjectIconView(
        "New project",
        callback: createNewProjectCallBack,
      ),
      ...Provider.of<StateProvider>(context)
          .projects
          .map((project) => ProjectTileView(project))
    ]));
  }
}
