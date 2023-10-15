import 'package:dreamer_app/components/future_builder_wrapper.dart';
import 'package:dreamer_app/components/project_section_view.dart';
import 'package:dreamer_app/models/project.dart';
import 'package:dreamer_app/models/project_section.dart';
import 'package:dreamer_app/providers/app_state_data_provider.dart';
import 'package:dreamer_app/providers/project_section_data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

List<String> acceptedAudioExtensions = List.unmodifiable(["m4a", "mp3", "wav"]);
const String delimiter = "{:::}";
class ProjectView extends StatefulWidget {
  final Project project;

  ProjectView({required this.project});

  @override
  State<ProjectView> createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  late Project project = widget.project;

  List<PlatformFile> audioFileList = [];
  List<double> timestampList = [];
  List<String> lyricList = [];

  late ProjectSectionDataProvider projectSectionDataProvider;
  late Future<List<ProjectSection>> _getProjectSections;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    projectSectionDataProvider =
        Provider.of<ProjectSectionDataProvider>(context);
    _getProjectSections =
        projectSectionDataProvider.getProjectSections(project.id!);
  }

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
        FutureBuilderWrapper(_getProjectSections, (context, snapshot) {
          List<ProjectSection>? sections = snapshot.data;
          print(sections);
          if (sections == null || sections.isEmpty) {
            print('empty sections');
            return ProjectSectionView(
                ProjectSection(projectId: project.id!, sectionOrder: 0));
          } else {
            return Column(
              children: [
                ...sections.map(
                      (section) => ProjectSectionView(section)),
              ],
            );
          }
        }),
      ],
    );
  }
}

