import 'package:dreamer_app/models/project.dart';
import 'package:dreamer_app/providers/app_state_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectView extends StatefulWidget {
  final Project project;

  ProjectView({required this.project});

  @override
  State<ProjectView> createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  late Project project = widget.project;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppBar(
            title: Text(project.name),
            leading: FloatingActionButton(
              shape: CircleBorder(),
              onPressed: () {
                Provider.of<AppStateDataProvider>(context, listen: false)
                    .updateCurrentProjectAppState(null);
              },
              child: Icon(Icons.arrow_back),
            )),
        Text(project.description ?? "No Description"),
      ],
    );
  }
}

