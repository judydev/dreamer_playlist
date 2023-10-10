import 'package:dreamer_app/helper.dart';
import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/popups/edit_project_view.dart';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const double cardWidth = 240;
const double cardHeight = 160;
const double buttonSize = 32;

class ProjectGridView extends StatelessWidget {
  final Project project;
  final int index;
  final Function setCurrentProjectCallback;

  ProjectGridView(this.project, this.index, this.setCurrentProjectCallback);

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);
    
    return (SizedBox(
        // width: MediaQuery.of(context).size.width / 5 - 50,
        width: cardWidth,
        height: cardHeight,
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: InkWell(
                onTap: () {
                  stateProvider.currentProject = project;
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // SizedBox(
                    //   width: 240,
                    //   height: 40,
                    // ),
                    // Padding(padding: EdgeInsets.all(10)),
                    Text(project.name),
                    Text(project.description ?? "No description"),
                    // SizedBox(
                    //   width: 240,
                    //   height: 40,
                    // ),
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
    String oldName = project.name;

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
                      if (project.name.isEmpty)
                        {print("name cannot be empty when editing project")}
                      else
                        {
                          // TODO: add empty input validator, or disable OK button when empty
                          LocalStorage().editProject(project, oldName).then(
                            (newProject) {
                              setCurrentProjectCallback(newProject, index);
                            },
                          )
                        }
                    })
          ],
        );
      },
    );
  }

  deleteProject(context) {
    StateProvider stateProvider =
        Provider.of<StateProvider>(context, listen: false);

    return showAlertDialogPopup(context, "Warning",
        Text("Are you sure you want to delete project ${project.name}?"), [
      displayTextButton(context, "Yes", callback: () async {
        await LocalStorage().deleteProject(project.name);
        stateProvider.projects.remove(project);
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
    StateProvider stateProvider =
        Provider.of<StateProvider>(context, listen: false);

    Project project = Project(name: "");

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Project"),
          content: EditProjectView(project, (Project proj) {
            print('New Project showDialog');
            print(proj.name);
            print(proj.description);
            project = proj;
          }),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () => {
                      if (project.name.isEmpty)
                        {
                          print("name cannot be empty"),
                        }
                      else
                        {
                          // project.uuid = Uuid().v4(),
                          // TODO: add empty input validator, or disable OK button when empty
                          LocalStorage().initProject(project).then(
                            (newProject) {
                              stateProvider.currentProject = newProject;
                            },
                          )
                        }
                    })
          ],
        );
      },
    );
  }
}
