import 'package:audioplayers/audioplayers.dart';
import 'package:dreamer_app/helper.dart';
import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/lyrics_view.dart';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/project_icon_view.dart';
import 'package:dreamer_app/providers.dart';
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
  late Project project;

  AudioPlayer audioFilePlayer = AudioPlayer();
  bool isAudioFilePlaying = false;

  AudioPlayer recordingPlayer = AudioPlayer();
  bool isRecordingPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  bool isEditing = true;
  bool isLooping = false;

  List<PlatformFile> audioFileList = [];

  int loopStart = 0;
  int loopEnd = 0;

  List<double> timestampList = [];
  List<String> lyricList = [];

  @override
  void initState() {
    super.initState();
    project = widget.project;

    LocalStorage().readProject(project).then(
      (fullProject) {
        setState(() {
          project = fullProject;
        });

        StateProvider stateProvider =
            Provider.of<StateProvider>(context, listen: false);
        stateProvider.currentProject = project;
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
        AppBar(
            title: Text(project.name),
            leading: FloatingActionButton(
              shape: CircleBorder(),
              onPressed: () {
                Provider.of<StateProvider>(context, listen: false)
                    .currentProject = null;
              },
              child: Icon(Icons.arrow_back),
            )),
        Text(project.description ?? "No Description"),
        Row(
          children: [
            ProjectIconView("Import an audio file", callback: _openFilePicker),
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
          thumbColor: Colors.amber,
          activeColor: Colors.amberAccent,
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
              backgroundColor: isEditing ? Colors.amberAccent : Colors.grey,
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
        LyricsView(isEditing),
      ],
    );
  }
}

buildLyricsLineField(lyrics) {
  return ([for (final line in lyrics.split(delimiter)) Text(line)]);
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
