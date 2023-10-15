import 'package:dreamer_app/components/audio_player_view.dart';
import 'package:dreamer_app/components/lyrics_view.dart';
import 'package:dreamer_app/components/project_icon_view.dart';
import 'package:dreamer_app/helpers/helper.dart';
import 'package:dreamer_app/models/project_section.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ProjectSectionView extends StatefulWidget {
  final ProjectSection section;

  ProjectSectionView(this.section);

  @override
  State<ProjectSectionView> createState() => _ProjectSectionViewState();
}

class _ProjectSectionViewState extends State<ProjectSectionView> {
  late ProjectSection section = widget.section;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildAudioSection(section),
        SizedBox(height: 20),
        LyricsView(section.lyricsId),
      ],
    );
  }

  buildAudioSection(ProjectSection? section) {
    print('buildSection');
    print(section);
    if (section == null || section.audioFileId == null) {
      return ProjectIconView("Import an audio file", callback: _openFilePicker);
    } else {
      return AudioPlayerView(audioFileId: section.audioFileId);
    }
  }

  void _openFilePicker() {
    FilePicker.platform.pickFiles().then((selectedFile) => {
          processSelectedFile(
              context,
              selectedFile,
              // audioFilePlayer,
              (file) => {
                    setState(() {
                      // audioFileList.add(file);
                      // isAudioFilePlaying = true;
                    })
                  })
        });
  }

  processSelectedFile(context, selectedFile, callback) {
    if (selectedFile != null) {
      for (final file in selectedFile.files) {
        if (acceptedAudioExtensions.contains(file.extension)) {
          // audioFilePlayer.play(DeviceFileSource(file.path!));
          callback(file);
        } else {
          showAlertDialogPopup(
              context,
              "Warning",
              Text("The file you selected is not an audio file."),
              [displayTextButton(context, "OK")]);
        }
      }
    }
  }
}

List<String> acceptedAudioExtensions = List.unmodifiable(["m4a", "mp3", "wav"]);
const String delimiter = "{:::}";
