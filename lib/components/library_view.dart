import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/components/songlist_view.dart';
import 'package:dreamer_playlist/helpers/audio_handler.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class LibraryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppBar(title: Text('All Songs')),
        libraryButtonBar,
        TextButton(
            onPressed: () {
              openFilePicker(context, null);
            },
            child: Text("Import local file to Library")),
        SongListView()
      ],
    );
  }
}

// TODO: compare performance with using class
ButtonBar libraryButtonBar = ButtonBar(
  alignment: MainAxisAlignment.spaceEvenly,
  children: [
    // Edit
    IconButton(
        onPressed: () {
          print('TODO: batch edit songs (e.g. batch delete)');
        },
        icon: Icon(Icons.edit)),
    // Play
    IconButton(
        onPressed: () {
          play(
              hasShuffleModeChanged:
                      GetitUtil.audioHandler.audioPlayer.shuffleModeEnabled)
              .then((value) => print('play success'))
              .catchError((e) {
            print('play error');
            debugPrint(e);
          });
        },
        icon: Icon(Icons.play_circle, size: 42)),
    // Shuffle
    IconButton(
        onPressed: () {
          shufflePlay()
              .then((value) => print('shufflePlay success'))
              .catchError((e) {
            print('shufflePlay error');
            debugPrint(e);
          });
        },
        icon: Icon(Icons.shuffle)),
  ],
);

Future<void> shufflePlay() async {
  AudioPlayer audioPlayer = GetitUtil.audioHandler.audioPlayer;
  MyAudioHandler audioHandler = GetitUtil.audioHandler;
  if (isEmptyQueue()) {
    await audioHandler.resetQueueFromSonglist(GetitUtil.orderedSongList);
  }
  if (isEmptyQueue()) return;

  if (audioPlayer.shuffleModeEnabled) {
    // shuffle already enabled, re-shuffle
    await audioPlayer.shuffle();
  } else {
    await audioPlayer.setShuffleModeEnabled(true);
  }

  await Future.delayed(Duration(milliseconds: 10), () => {}); // TODO

  updateQueueIndicesNotifier();
  int firstIndex = audioPlayer.effectiveIndices![0];
  await audioHandler.skipToQueueItem(firstIndex);
  await audioHandler.play();
}

Future<void> play(
    {bool hasShuffleModeChanged = false, int songIndex = 0}) async {
  MyAudioHandler audioHandler = GetitUtil.audioHandler;
  AudioPlayer audioPlayer = audioHandler.audioPlayer;
  await audioHandler
      .resetQueueFromSonglist(GetitUtil.orderedSongList);
  if (isEmptyQueue()) return;

  if (hasShuffleModeChanged) {
    bool oldShuffleMode = audioPlayer.shuffleModeEnabled;
    await audioPlayer.setShuffleModeEnabled(!oldShuffleMode);
  }

  updateQueueIndicesNotifier();
  currentIndexNotifier.value = songIndex;
  await audioHandler.play();
}
