import 'package:dreamer_app/helpers/helper.dart';
import 'package:dreamer_app/popups/edit_project_view.dart';
import 'package:dreamer_app/models/project.dart';
import 'package:dreamer_app/providers/app_state_data_provider.dart';
import 'package:dreamer_app/providers/project_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

const double cardWidth = 240;
const double cardHeight = 160;
const double buttonSize = 32;

class ProjectGridView extends StatefulWidget {
  final Project project;
  final int index;
  final Function setCurrentProjectCallback;
  
  ProjectGridView(this.project, this.index, this.setCurrentProjectCallback);

  @override
  State<StatefulWidget> createState() => _ProjectsGridViewState();
}

class _ProjectsGridViewState extends State<ProjectGridView> {
  late Project project;
  late int index;
  late Function setCurrentProjectCallback;

  @override
  void initState() {
    super.initState();

    project = widget.project;
    index = widget.index;
    setCurrentProjectCallback = widget.setCurrentProjectCallback;
  }

  @override
  Widget build(BuildContext context) {    
    return (SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: InkWell(
                onTap: () {
                  Provider.of<AppStateDataProvider>(context, listen: false)
                      .updateCurrentProjectAppState(project.id!);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(project.name),
                    Text(project.description ?? "No description"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                    SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: InkWell(
                                onTap: () {
                                  editProject(context, project, index);
                                },
                                child: Icon(Icons.edit))),
                    SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: InkWell(
                                onTap: () {
                                  deleteProject(context);
                                },
                                child: Icon(Icons.delete_outlined))),
                      ],
                    ),
                  ],
                )))));
  }

  editProject(BuildContext context, Project project, int index) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Project"),
          content: EditProjectView(project, (Project proj) {
            project = proj;
          }),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () => {
                      // TODO: add empty input validator, or disable OK button when empty
                      if (project.name.isEmpty)
                        {print("name cannot be empty when editing project")}
                      else
                        {
                          Provider.of<ProjectDataProvider>(context,
                                  listen: false)
                              .updateProject(project)
                        }
                    })
          ],
        );
      },
    );
  }
  deleteProject(context) {
    ProjectDataProvider projectDataProvider =
        Provider.of<ProjectDataProvider>(context, listen: false);

    return showAlertDialogPopup(context, "Warning",
        Text("Are you sure you want to delete project ${project.name}?"), [
      displayTextButton(context, "Yes", callback: () async {
        await projectDataProvider.deleteProject(project.id!);
      }),
      displayTextButton(context, "No")
    ]);
  }
}

class NewProjectCardView extends StatefulWidget {
  NewProjectCardView();

  @override
  State<StatefulWidget> createState() => _NewProjectCardViewState();
}

class _NewProjectCardViewState extends State<NewProjectCardView> {

  @override
  Widget build(BuildContext context) {
    return (SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: InkWell(
                onTap: () {
                  createNewProject(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add),
                    Text("New Project"),
                  ],
                )))));
  }

  createNewProject(context) {
    Project project = Project(id: Uuid().v4(), name: "");

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Project"),
          content: EditProjectView(project, (Project proj) {
            project = proj;
          }),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () async => {
                      // TODO: add empty input validator, or disable OK button when empty
                      if (project.name.isEmpty)
                        {
                          print("name cannot be empty"),
                        }
                      else
                        {
                          await Provider.of<ProjectDataProvider>(context,
                                  listen: false)
                              .addProject(project)
                        }
                    })
          ],
        );
      },
    );
  }
}
