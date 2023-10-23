import 'package:dreamer_playlist/components/playlist_edit_songlist.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:flutter/material.dart';

class EditPlaylistPopup extends StatefulWidget {
  final Playlist playlist;
  const EditPlaylistPopup(this.playlist);

  @override
  State<EditPlaylistPopup> createState() => _EditPlaylistPopupState();
}

class _EditPlaylistPopupState extends State<EditPlaylistPopup> {
  late Playlist playlist = widget.playlist;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        TextButton(
            onPressed: () {
              print('done editing playlist, save change and close popup');

              Navigator.of(context).pop();
            },
            child: Text('Done')),
      ]),
      body: Column(children: [
        Stack(
          children: [
            Text(playlist.name!),
            TextField(),
          ],
        ),
        Stack(
          children: [
            Text('Field for Playlist description'),
            TextField(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('N tracks'), Text('sort')],
        ),
        PlaylistEditSongList(playlist) // cached?
      ]),
    );
  }
}
