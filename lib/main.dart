import 'package:dreamer_app/projects_view.dart';
import 'package:dreamer_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:dreamer_app/project_view.dart';
import 'package:provider/provider.dart';

void main() {
runApp(
    ChangeNotifierProvider<StateProvider>(
      create: (_) => StateProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreamer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("Dreamer"),
            leading: FloatingActionButton(
              onPressed: () {
                Provider.of<StateProvider>(context, listen: false)
                    .currentProject = null;
              },
              backgroundColor: Colors.amber,
              child: Icon(Icons.menu),
            )),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Provider.of<StateProvider>(context).currentProject == null
              ? ProjectsView()
            : ProjectView(
                  project: Provider.of<StateProvider>(context).currentProject!,
                ),
        )
      );
  }
}
