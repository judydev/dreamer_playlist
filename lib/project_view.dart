import 'package:audioplayers/audioplayers.dart';
import 'package:dreamer_app/helper.dart';
import 'package:dreamer_app/lyrics_view.dart';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/project_icon_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

List<String> acceptedAudioExtensions = List.unmodifiable(["m4a", "mp3", "wav"]);

class ProjectView extends StatefulWidget {
  final Project project;
  ProjectView({required this.project});

  @override
  State<ProjectView> createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  late Project project;

  // _ProjectViewState(this.project);

  AudioPlayer audioFilePlayer = AudioPlayer();
  bool isAudioFilePlaying = false;

  AudioPlayer recordingPlayer = AudioPlayer();
  bool isRecordingPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  bool isEditing = false;

  List<PlatformFile> audioFileList = [];
  String lyrics = "";

  @override
  void initState() {
    super.initState();

    project = widget.project;

    setState(() {
      audioFilePlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          isAudioFilePlaying = state == PlayerState.playing;
        });
      });

      audioFilePlayer.onPositionChanged.listen((newPosition) {
        setState(() {
          position = newPosition;
        });
      });

      audioFilePlayer.onDurationChanged.listen((newDuration) {
        setState(() {
          duration = newDuration;
        });
      });

      // todo: replay the same file
      // audioFilePlayer.onPlayerComplete.listen((event) {
      //   audioFilePlayer.play(audioFilePlayer.source!);
      // });
    });
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  void _selectFile() {
    FilePicker.platform.pickFiles().then((selectedFile) => {
          processSelectedFile(
              context,
              selectedFile,
              audioFilePlayer,
              (file) => {
                    setState(() {
                      audioFileList.add(file);
                      isAudioFilePlaying = true;
                    })
                  })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ProjectIconView("Import", _selectFile),
        Row(
          children: [
            ...audioFileList.map((file) => FloatingActionButton(
                  onPressed: () => {
                    audioFilePlayer.play(DeviceFileSource(file.path!)),
                    setState(() => isAudioFilePlaying = true)
                  },
                  heroTag: null,
                  tooltip: file.name,
                  child: const Icon(Icons.audio_file),
                )),
          ],
        ),
        Slider(
          min: 0.0,
          max: duration.inSeconds.toDouble(),
          value: position.inSeconds.toDouble(),
          onChanged: (value) {
            final position = Duration(seconds: value.toInt());
            audioFilePlayer.seek(position);
            audioFilePlayer.resume();
          },
        ),
        Row(
          children: [
            FloatingActionButton(
              onPressed: audioFilePlayer.source == null
                  ? null
                  : () => {
                        if (isAudioFilePlaying)
                          {
                            audioFilePlayer.pause(),
                            setState(() => isAudioFilePlaying = false)
                          }
                        else
                          {
                            audioFilePlayer.resume(),
                            setState(() => isAudioFilePlaying = true)
                          }
                      },
              heroTag: null,
              tooltip: isAudioFilePlaying ? 'Pause' : 'Play',
              child: isAudioFilePlaying
                  ? Icon(Icons.pause_circle)
                  : Icon(Icons.play_arrow),
            ),
            FloatingActionButton(
              onPressed: () => {
                setState(() {
                  isEditing = !isEditing;
                }),
              },
              heroTag: null,
              tooltip: 'Edit',
              child: Icon(Icons.edit),
            )
          ],
        ),
        isEditing
            ? TextFormField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                initialValue: lyrics,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Add lyrics here',
                ),
                onChanged: (value) {
                  setState(() {
                    lyrics = value;
                  });
                },
              )
            : Expanded(
                child: SizedBox(height: 500, child: LyricsView(lyrics)),
              )
      ],
    );
  }
}

buildLyricsLineField(lyrics) {
  return ([for (final line in lyrics.split("\n")) Text(line)]);
}

processSelectedFile(context, selectedFile, audioFilePlayer, callback) {
  if (selectedFile != null) {
    for (final file in selectedFile.files) {
      if (acceptedAudioExtensions.contains(file.extension)) {
        audioFilePlayer.play(DeviceFileSource(file.path!));
        callback(file);
      } else {
        showDialogPopup(
            context,
            "Warning",
            Text("The file you selected is not an audio file."),
            [displayTextButton(context, "OK")]);
      }
    }
  }
}
