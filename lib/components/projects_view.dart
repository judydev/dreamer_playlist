import 'package:dreamer_app/components/future_builder_wrapper.dart';
import 'package:dreamer_app/components/project_grid_view.dart';
import 'package:dreamer_app/providers/project_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:dreamer_app/models/project.dart';
import 'package:provider/provider.dart';

class ProjectsView extends StatefulWidget {
  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  late ProjectDataProvider projectDataProvider;
  late Future<List<Project>> _getAllProjects;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    projectDataProvider = Provider.of<ProjectDataProvider>(context);
    _getAllProjects = projectDataProvider.getAllProjects();
  }

  @override
  Widget build(BuildContext context) {
    return (Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      AppBar(
        title: Text("All Projects"),
      ),
      FutureBuilder(
          future: _getAllProjects,
          builder: ((context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Text("Loading projects...");
            } else if (snapshot.hasError) {
              return ErrorView(snapshot.error.toString());
            } else {
              List<Project> projects = snapshot.data ?? [];
              return Wrap(
                direction: Axis.horizontal,
                clipBehavior: Clip.hardEdge,
                spacing: 30,
                runSpacing: 20,
                children: [
                  NewProjectCardView(),
                  ...projects.asMap().entries.map((entry) => ProjectGridView(
                          entry.value, entry.key, (editedProject, index) {
                        projects[index] = editedProject;
                      })),
                ],
              );
            }
          })),
    ]));
  }
}
