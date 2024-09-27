import 'package:dreamer_playlist/components/edit_library_popup.dart';
import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/components/songlist_view.dart';
import 'package:dreamer_playlist/helpers/audio_handler.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class LibraryTabView extends StatefulWidget {
  @override
  State<LibraryTabView> createState() => _LibraryTabViewState();
}

class _LibraryTabViewState extends State<LibraryTabView> {
  bool isPopupOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Songs')),
      body: Column(
        children: <Widget>[
          getLibraryButtonBar(context),
          TextButton(
              onPressed: () async {
                if (isPopupOpen) return;
                isPopupOpen = true;
                await openFilePicker(context, null);
                isPopupOpen = false;
              },
              child: const Text("Import local file to Library")),
          Expanded(child: SongListView())
        ],
      ),
    );
  }
}

OverflowBar getLibraryButtonBar(context) => OverflowBar(
  alignment: MainAxisAlignment.spaceEvenly,
  children: [
    // Edit
    IconButton(
        onPressed: () {
              showAdaptiveDialog(
                  context: context, builder: (context) => EditLibraryPopup());
        },
            icon: const Icon(Icons.edit)),
    // Play
    IconButton(
        onPressed: () {
          play(
              hasShuffleModeChanged:
                  GetitUtil.audioHandler.audioPlayer.shuffleModeEnabled);
        },
            icon: const Icon(Icons.play_circle, size: 42)),
    // Shuffle
    IconButton(
        onPressed: () {
          shufflePlay();
        },
            icon: const Icon(Icons.shuffle)),
  ],
);

Future<void> shufflePlay() async {
  AudioPlayer audioPlayer = GetitUtil.audioHandler.audioPlayer;
  MyAudioHandler audioHandler = GetitUtil.audioHandler;

  await audioHandler.resetQueueFromSonglist(GetitUtil.orderedSongList);
  if (isEmptyQueue()) return;

  if (audioPlayer.shuffleModeEnabled) {
    // shuffle already enabled, re-shuffle
    await audioPlayer.shuffle();
  } else {
    await audioPlayer.setShuffleModeEnabled(true);
  }

  updateQueueIndicesNotifier();
  int firstIndex = audioPlayer.effectiveIndices![0];
  await audioHandler.skipToQueueItem(firstIndex);
}

Future<void> play(
    {bool hasShuffleModeChanged = false, int songIndex = 0}) async {
  MyAudioHandler audioHandler = GetitUtil.audioHandler;
  AudioPlayer audioPlayer = audioHandler.audioPlayer;
  await audioHandler.resetQueueFromSonglist(GetitUtil.orderedSongList);
  if (isEmptyQueue()) return;

  if (hasShuffleModeChanged) {
    bool oldShuffleMode = audioPlayer.shuffleModeEnabled;
    await audioPlayer.setShuffleModeEnabled(!oldShuffleMode);
  }

  updateQueueIndicesNotifier();
  currentIndexNotifier.value = songIndex;
  await audioHandler.play();
}
