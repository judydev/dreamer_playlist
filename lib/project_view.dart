import 'package:audioplayers/audioplayers.dart';
import 'package:dreamer_app/helper.dart';
import 'package:dreamer_app/local_storage.dart';
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

  AudioPlayer audioFilePlayer = AudioPlayer();
  bool isAudioFilePlaying = false;

  AudioPlayer recordingPlayer = AudioPlayer();
  bool isRecordingPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  bool isEditing = false;
  bool isLooping = false;

  List<PlatformFile> audioFileList = [];
  String lyrics = "";

  int loopStart = 0;
  int loopEnd = 0;

  @override
  void initState() {
    super.initState();
    project = widget.project;

    LocalStorage().getLyricsFile(project.name).then(
      (file) {
        setState(() {
          lyrics = file.readAsStringSync();
        });
      },
    );

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

      audioFilePlayer.setReleaseMode(ReleaseMode.loop);
    });
  }

  loop() {
    if (isLooping) {
      setState(() {
        position = Duration(milliseconds: loopStart);
        isAudioFilePlaying = true;
        audioFilePlayer.seek(position);
        audioFilePlayer.resume();
      });
    } else {
      setState(() {
        isAudioFilePlaying = false;
        audioFilePlayer.pause();
      });
    }
  }

  // String formatTime(int seconds) {
  //   return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  // }

  void _openFilePicker() {
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
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ProjectIconView("Import", callback: _openFilePicker),
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
          thumbColor: Colors.green,
          activeColor: Colors.greenAccent,
          inactiveColor: Colors.lightGreenAccent,
          max: duration.inMilliseconds.toDouble(),
          value: position.inMilliseconds.toDouble(),
          onChanged: ((double value) {
            Duration newPosition = Duration(milliseconds: value.toInt());
            audioFilePlayer.seek(newPosition);
            audioFilePlayer.resume();

            setState(() {
              position = newPosition;
            });
          }),
        ),
        Row(
          children: [
            FloatingActionButton(
              backgroundColor: isAudioFilePlaying ? Colors.pink : Colors.grey,
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
            ),
            FloatingActionButton(
              backgroundColor: isLooping ? Colors.blueAccent : Colors.grey,
              onPressed: () => {
                loop(),
                setState(() {
                  isLooping = !isLooping;
                }),
              },
              heroTag: null,
              tooltip: 'Loop',
              child: Icon(Icons.loop),
            ),
          ],
        ),
        LyricsView(lyrics, isEditing),
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
        showAlertDialogPopup(
            context,
            "Warning",
            Text("The file you selected is not an audio file."),
            [displayTextButton(context, "OK")]);
      }
    }
  }
}
