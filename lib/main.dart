import 'package:dreamer_app/components/future_builder_wrapper.dart';
import 'package:dreamer_app/models/project.dart';
import 'package:dreamer_app/components/projects_view.dart';
import 'package:dreamer_app/providers/app_state_data_provider.dart';
import 'package:dreamer_app/providers/lyrics_data_provider.dart';
import 'package:dreamer_app/providers/project_data_provider.dart';
import 'package:dreamer_app/providers/database_util.dart';
import 'package:dreamer_app/providers/project_section_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:dreamer_app/components/project_view.dart';
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
      ChangeNotifierProvider<ProjectSectionDataProvider>(
        create: (context) => ProjectSectionDataProvider(),
      ),
      ChangeNotifierProvider<LyricsDataProvider>(
        create: (context) => LyricsDataProvider(),
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
