import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/models/project.dart';
import 'package:dreamer_playlist/components/projects_view.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:dreamer_playlist/providers/project_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:dreamer_playlist/components/project_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseUtil.initDatabase();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<ProjectDataProvider>(
        create: (context) => ProjectDataProvider(),
      ),
      ChangeNotifierProvider<AppStateDataProvider>(
        create: (context) => AppStateDataProvider(),
      ),
    ], child: MyApp()),
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
  late AppStateDataProvider appStateDataProvider;
  late Future<Project?> _getCurrentProjectAppState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    appStateDataProvider = Provider.of<AppStateDataProvider>(context);
    _getCurrentProjectAppState =
        appStateDataProvider.getCurrentProjectAppState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
            child: FutureBuilderWrapper(_getCurrentProjectAppState,
                (context, snapshot) {
              Project? currentProject = snapshot.data;
                    if (currentProject == null) {
                      return ProjectsView();
                    } else {
                      return ProjectView(project: currentProject);
                    }
            })));
  }
}
