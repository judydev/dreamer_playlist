import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:flutter/material.dart';

class SongTileReorder extends StatefulWidget {
  final String songName;
  SongTileReorder(this.songName);

  @override
  State<StatefulWidget> createState() => _SongTileReorderState();
}

class _SongTileReorderState extends State<SongTileReorder> {
  late String songName = widget.songName;

  @override
  Widget build(BuildContext context) {
    // TODO: make this tile draggable for re-ordering
    return ListTileWrapper(
      title: songName,
      leading: Icon(Icons.music_video),
      trailing: Icon(Icons.menu),
      onTap: () {},
    );
  }
}
