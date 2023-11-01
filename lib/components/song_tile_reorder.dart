import 'package:dreamer_playlist/components/library_view.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:flutter/material.dart';

class SongTileReorder extends StatelessWidget {
  final String songName;
  final int songIndex;
  SongTileReorder({required this.songName, required this.songIndex});

  @override
  Widget build(BuildContext context) {
    // TODO: make this tile draggable for re-ordering
    return ListTileWrapper(
      title: songName,
      leading: Icon(Icons.music_video),
      trailing: Icon(Icons.menu),
      onTap: () {
        print('SongTileReorder songIndex = $songIndex');
        play(songIndex: songIndex, hasShuffleModeChanged: false);
      },
    );
  }
}
