import 'package:flutter/material.dart';
import 'package:dreamer_app/project_icon_view.dart';
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // AudioCache audioCache = AudioCache(prefix: 'assets/audio/');
  List<Project> projects = [];
  Project? currentProject;

  setCurrentProjectCallBack() {
    setState(
      () {
        currentProject ??= Project(isNew: true);
      },
    );
    print(currentProject != null);
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
                  currentProject = Project(isEmpty: true);
                });
              },
              backgroundColor: Colors.amber,
              child: Icon(Icons.menu),
            )),
        resizeToAvoidBottomInset: false,
        body: currentProject == null
            ? ProjectIconView("New project", setCurrentProjectCallBack)
            : ProjectView(
                project: currentProject ?? Project(),
              )      
        );
  }
}
