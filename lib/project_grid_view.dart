import 'package:dreamer_app/helper.dart';
import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const double cardWidth = 240;
const double cardHeight = 160;
const double buttonSize = 32;

class ProjectGridView extends StatelessWidget {
  final Project project;

  ProjectGridView(this.project);

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context, listen: false);

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
                    SizedBox(
                      width: 240,
                      height: 40,
                    ),
                    // Padding(padding: EdgeInsets.all(10)),
                    Text(project.name),
                    SizedBox(
                      width: 240,
                      height: 40,
                    ),
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: FloatingActionButton(
                          tooltip: "delete",
                          onPressed: () {
                            deleteProject(context);
                        },
                        child: Icon(Icons.delete_outline),
                      ),
                    ),
                  ],
                )))));
  }

  editProject(BuildContext context, Project project) {
    String projectName = project.name;
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Project"),
          // TODO: consolidate editProject() with createNewProject(), make a form widget
          content: TextField(),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () => {
                      LocalStorage().initProject(projectName).then(
                        (value) {
                          Provider.of<StateProvider>(context, listen: false)
                                  .currentProject =
                              Project(name: projectName, isNew: true);
                        },
                      )
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
  String projectName = "";

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
    String projectName = "";
    StateProvider stateProvider =
        Provider.of<StateProvider>(context, listen: false);
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Project"),
          content: TextField(
            decoration: InputDecoration(
              labelText: "Project Name",
            ),
            onChanged: (value) {
              setState(() {
                projectName = value;
              });
            },
          ),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () => {
                      // TODO: add empty input validator, or disable OK button when empty
                      LocalStorage().initProject(projectName).then(
                        (value) {
                          stateProvider.currentProject =
                              Project(name: projectName, isNew: true);
                        },
                      )
                    })
          ],
        );
      },
    );
  }
}
