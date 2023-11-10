import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';

class SongTileSelect extends StatefulWidget {
  final Song song;
  final Function callback;
  final IconData? selectIcon;
  SongTileSelect({required this.song, required this.callback, this.selectIcon});

  @override
  State<SongTileSelect> createState() => _SongTileSelectState();
}

class _SongTileSelectState extends State<SongTileSelect> {
  late Song song = widget.song;
  late Function callback = widget.callback;
  late IconData? selectIcon = widget.selectIcon;

  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
        title: song.title!,
        leading: Icon(Icons.music_video),
        trailing: IconButton(
          icon: isSelected
              ? Icon(Icons.check_circle)
              : Icon(selectIcon ?? Icons.circle_outlined),
          onPressed: () {
            setState(() {
              isSelected = !isSelected;
            });

            callback(song);
          },
        ),
        onTap: null);
  }
}
