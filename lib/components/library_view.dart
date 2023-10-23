import 'package:dreamer_playlist/components/playlist_view_songlist.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:flutter/material.dart';

class LibraryView extends StatefulWidget {
  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppBar(
          title: Text('All Songs'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  print('TODO: batch edit songs (e.g. batch delete)');
                },
                icon: Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  print('LibraryView.play');
                  print(GetitUtil.songList);
                  if (GetitUtil.audioPlayer.audioSource == null) {
                    return;
                  }

                  GetitUtil.currentlyPlaying.value = GetitUtil.songList.first;
                  GetitUtil.audioPlayer.play();
                },
                icon: Icon(Icons.play_circle, size: 42)),
            IconButton(
                onPressed: () {
                  print('TODO: shuffle play all songs');
                  GetitUtil.audioPlayer.shuffle();
                  GetitUtil.audioPlayer.play();
                },
                icon: Icon(Icons.shuffle)),
          ],
        ),
        TextButton(
            onPressed: () {
              openFilePicker(context, null);
            },
            child: Text("Import local file to Library")),
        PlaylistViewSongList(null)
      ],
    );
  }
}
