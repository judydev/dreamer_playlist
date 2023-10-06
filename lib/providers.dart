import 'package:dreamer_app/project.dart';
import 'package:flutter/material.dart';

class StateProvider extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _currentProject;

  List<Project> get projects => _projects;

  set projects(List<Project> projectList) {
    _projects = projectList;
    notifyListeners();
  }

  Project? get currentProject => _currentProject;

  set currentProject(Project? curProj) {
    _currentProject = curProj;
    notifyListeners();
  }
}
