import 'package:dreamer_app/models/project_section.dart';
import 'package:dreamer_app/providers/database_util.dart';
import 'package:flutter/material.dart';

class ProjectSectionDataProvider extends ChangeNotifier {
  Future<List<ProjectSection>> getProjectSections(String projectId) async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('project_sections', where: 'projectId = "$projectId"');
    List<ProjectSection> sections = List.generate(maps.length, (i) {
      return ProjectSection(
          id: maps[i]['id'],
          projectId: projectId,
          sectionOrder: maps[i]['order'],
          audioFileId: maps[i]['audioFileId'],
          recordingFileId: maps[i]['recordingFileId'],
          lyricsId: maps[i]['lyricsId']);
    });

    return sections;
  }

  Future<void> updateProjectSection(ProjectSection section) async {
    final db = await DatabaseUtil.getDatabase();
    await db.update(
      'project_sections',
      section.toMap(),
      where: 'id = ?',
      whereArgs: [section.id],
    );

    notifyListeners();
  }

  Future<void> deleteProjectSection(String sectionId) async {
    final db = await DatabaseUtil.getDatabase();

    await db.delete(
      'project_sections',
      where: 'id = ?',
      whereArgs: [sectionId],
    );

    notifyListeners();
  }
}
