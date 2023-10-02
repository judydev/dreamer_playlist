import 'package:dreamer_app/helper.dart';
import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/projects_view.dart';
import 'package:flutter/material.dart';
import 'package:dreamer_app/project_view.dart';
import 'package:dreamer_app/project.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreamer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: MyHomePage(storage: LocalStorage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.storage});

  final LocalStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Project> projects = [];
  Project? currentProject;

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
                      widget.storage.initProject(songName).then(
                        (value) {
                          setState(
                            () {
                              currentProject =
                                  Project(name: songName, isNew: true);
                            },
                          );
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
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("Dreamer"),
            leading: FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentProject = null;
                });
              },
              backgroundColor: Colors.amber,
              child: Icon(Icons.menu),
            )),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: currentProject == null
              ? ProjectsView(
                  projects: projects,
                  storage: widget.storage,
                  callback: createNewProjectCallBack,
                  openProjectCallback: (Project project) {
                    setState(() {
                      currentProject = project;
                    });
                  })
            : ProjectView(
                  storage: widget.storage,
                  project: currentProject!,
                ),
        )
        );
  }
}
