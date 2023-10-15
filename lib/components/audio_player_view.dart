import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AudioPlayerView extends StatefulWidget {
  final String? audioFileId;

  AudioPlayerView({this.audioFileId});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  // late PlatformFile audioFile;

  AudioPlayer audioFilePlayer = AudioPlayer();
  bool isAudioFilePlaying = false;

  // AudioPlayer recordingPlayer = AudioPlayer();
  // bool isRecordingPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  bool isEditing = true;
  bool isLooping = false;

  int loopStart = 0;
  int loopEnd = 0;

  // TODO: query for audioFile associated with the section
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

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        FloatingActionButton(
          onPressed: () => {
            // audioFilePlayer.play(DeviceFileSource(audioFile.path!)),
            // setState(() => isAudioFilePlaying = true)
          },
          heroTag: null,
          // tooltip: audioFile.name,
          child: const Icon(Icons.audio_file),
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
      ],
    ));
  }
}
