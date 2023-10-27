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
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
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
        onPressed: () => play(loopMode: LoopMode.off),
        icon: Icon(Icons.play_circle, size: 42)),
    IconButton(
        onPressed: () => shufflePlay(),
        icon: Icon(Icons.shuffle)),
  ],
);

shufflePlay() {
  AudioPlayer audioPlayer = GetitUtil.audioPlayer;
  audioPlayer.setAudioSource(GetitUtil.queue);
  if (!audioPlayer.shuffleModeEnabled) {
    audioPlayer.setShuffleModeEnabled(true);
    updateShuffleModeNotifier();
  }
  audioPlayer.shuffle();
  updateQueueIndices();
  pauseStateNotifier.value = PauseState.playing;

  // set first in the updated queue
  currentlyPlayingNotifier.value =
      GetitUtil.orderedSongList[queueIndicesNotifier.value.first];
  audioPlayer.play();
}

play(
    {bool hasShuffleModeChanged = false,
    LoopMode? loopMode,
    int initialIndex = 0}) {
  if (GetitUtil.queue.children.isEmpty) {
    print('no songs in songList');
    return;
  }

  AudioPlayer audioPlayer = GetitUtil.audioPlayer;
  audioPlayer.setAudioSource(GetitUtil.queue,
      initialIndex: initialIndex, initialPosition: Duration.zero);

  if (hasShuffleModeChanged) {
    bool oldShuffleMode = audioPlayer.shuffleModeEnabled;
    audioPlayer.setShuffleModeEnabled(!oldShuffleMode);
    updateShuffleModeNotifier();
  }

  updateQueueIndices();
  pauseStateNotifier.value = PauseState.playing;

  if (loopMode != null) {
    loopModeNotifier.value = loopMode;
  }

  // set currentlyPlaying as the first in sequence
  currentlyPlayingNotifier.value = GetitUtil.queue.sequence[initialIndex].tag;
  audioPlayer.play();
}
