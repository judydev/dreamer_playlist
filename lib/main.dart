import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import './helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Dreamer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioFilePlayer = AudioPlayer();
  bool isAudioFilePlaying = false;
  List<String> acceptedAudioExtensions =
      List.unmodifiable(["m4a", "mp3", "wav"]);

  AudioPlayer recordingPlayer = AudioPlayer();
  bool isRecordingPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // AudioCache audioCache = AudioCache(prefix: 'assets/audio/');

  List<PlatformFile> audioFileList = [];

  @override
  void initState() {
    super.initState();

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
          print(selectedFile),
          if (selectedFile != null)
            {
              for (final file in selectedFile.files)
                {
                  if (acceptedAudioExtensions.contains(file.extension))
                    {
                      audioFilePlayer.play(DeviceFileSource(file.path!)),
                      setState(() {
                        audioFileList.add(file);
                        isAudioFilePlaying = true;
                      })
                    }
                  else
                    {
                      showDialogPopup(
                          context,
                          "Warning",
                          Text("The file you selected is not an audio file."),
                          [displayTextButton(context, "OK")])
                    }

                }
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Dreamer"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            FloatingActionButton(
              onPressed: () => {_selectFile()},
              heroTag: null,
              tooltip: 'Import',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: audioFilePlayer.source == null
                  ? null
                  : () => {
                        print('playerId'),
                        print(audioFilePlayer.playerId),
                        print(audioFilePlayer.source),
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
            )
          ],
        ),
      ),
    );
  }
}
