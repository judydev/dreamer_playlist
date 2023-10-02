import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/project_icon_view.dart';
import 'package:dreamer_app/project_tile_view.dart';
import 'package:flutter/material.dart';

// displays all existing projects
class ProjectsView extends StatefulWidget {
  final List<Project> projects;
  final LocalStorage storage;
  final Function callback;
  final Function openProjectCallback;

  ProjectsView(
      {required this.projects,
      required this.storage,
      required this.callback,
      required this.openProjectCallback});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  late List<Project> projects;
  late LocalStorage storage;

  @override
  void initState() {
    super.initState();

    projects = widget.projects;
    storage = widget.storage;
    for (var element in projects) {
      print(element);
    }

    widget.storage.readProjects().then((value) => {
          setState(
            () {
              projects = value;
            },
          )
        });
  }

  @override
  Widget build(BuildContext context) {
    return (Flex(direction: Axis.vertical, children: [
      ProjectIconView("New project", widget.callback),
      ...projects.map(
          (project) => ProjectTileView(project, widget.openProjectCallback))
    ]));
  }
}
