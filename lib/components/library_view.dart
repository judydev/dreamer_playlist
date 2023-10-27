import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/components/songlist_view.dart';
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
        SongList()
      ],
    );
  }
}

// TODO: compare performance with using class
ButtonBar libraryButtonBar = ButtonBar(
  alignment: MainAxisAlignment.spaceEvenly,
  children: [
    IconButton(
        onPressed: () {
          print('TODO: batch edit songs (e.g. batch delete)');
        },
        icon: Icon(Icons.edit)),
    IconButton(
        onPressed: () => play(
            loopMode: LoopMode.off,
            hasShuffleModeChanged: _audioPlayer.shuffleModeEnabled),
        icon: Icon(Icons.play_circle, size: 42)),
    IconButton(
        onPressed: () => shufflePlay(),
        icon: Icon(Icons.shuffle)),
  ],
);

AudioPlayer _audioPlayer = GetitUtil.audioPlayer;

shufflePlay() async {
  await _audioPlayer.setAudioSource(GetitUtil.queue);
  if (isEmptyQueue()) return;

  if (_audioPlayer.shuffleModeEnabled) {
    // shuffle already enabled, re-shuffle
    await _audioPlayer.shuffle();
  } else {
    await _audioPlayer.setShuffleModeEnabled(true);
  }

  updateQueueIndicesNotifier();
  pauseStateNotifier.value = PauseState.playing;

  await _audioPlayer.play();
}

play(
    {bool hasShuffleModeChanged = false,
    LoopMode? loopMode,
    int initialIndex = 0}) async {

  await _audioPlayer.setAudioSource(GetitUtil.queue,
      initialIndex: initialIndex, initialPosition: Duration.zero);
  if (isEmptyQueue()) return; 

  if (hasShuffleModeChanged) {
    bool oldShuffleMode = _audioPlayer.shuffleModeEnabled;
    await _audioPlayer.setShuffleModeEnabled(!oldShuffleMode);
  }

  updateQueueIndicesNotifier();
  pauseStateNotifier.value = PauseState.playing;

  if (loopMode != null) {
    loopModeNotifier.value = loopMode;
  }

  // set currentlyPlaying as the first in sequence
  currentlyPlayingNotifier.value = GetitUtil.queue.sequence[initialIndex].tag;
  await _audioPlayer.play();
}
