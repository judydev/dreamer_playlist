import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';

class SongTileSelect extends StatelessWidget {
  final Song song;
  final Function callback;
  final bool isSelected;
  final Icon? selectIcon;
 
  SongTileSelect({
    required this.song,
    required this.callback,
    required this.isSelected,
    this.selectIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
        title: song.title!,
        trailing: IconButton(
          icon: isSelected
              ? const Icon(Icons.check_circle)
              : selectIcon ?? const Icon(Icons.circle_outlined),
          onPressed: () {
            callback(song);
          },
        ),
        onTap: null);
  }
}
