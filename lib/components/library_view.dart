import 'package:dreamer_playlist/components/playlist_view_songlist.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
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
        AppBar(
          title: Text('All Songs')
        ),
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
        onPressed: () => play(),        
        icon: Icon(Icons.play_circle, size: 42)),
    IconButton(
        onPressed: () => play(isShuffle: true),
        icon: Icon(Icons.shuffle)),
  ],
);

play({bool isShuffle = false}) {
  if (GetitUtil.queue.children.isEmpty) {
    print('no songs in songList');
    return;
  }
  AudioPlayer audioPlayer = GetitUtil.audioPlayer;
  audioPlayer.setAudioSource(GetitUtil.queue,
      initialIndex: 0, initialPosition: Duration.zero);
  audioPlayer.setShuffleModeEnabled(isShuffle);
  GetitUtil.effectiveIndicesNotifier.value = audioPlayer.effectiveIndices;
  audioPlayer.play();
}
