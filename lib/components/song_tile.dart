import 'package:dreamer_playlist/components/list_item_view.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';

class SongTile extends StatefulWidget {
  final Song song;
  SongTile(this.song);

  @override
  State<StatefulWidget> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  late Song song = widget.song;
  @override
  Widget build(BuildContext context) {
    return ListItemView(
      title: song.name!,
      // leadingIcon: Icon(Icons.music),
      onTapAction: () {
        print(song.name);
        print(song.id);
      },
    );
  }
}
