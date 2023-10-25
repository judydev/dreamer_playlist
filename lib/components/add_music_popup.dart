import 'package:dreamer_playlist/components/add_music_song_list.dart';
// import 'package:dreamer_playlist/components/music_search_bar.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:flutter/material.dart';

class AddMusicPopup extends StatefulWidget {
  final Playlist? playlist;
  const AddMusicPopup(this.playlist);

  @override
  State<AddMusicPopup> createState() => _AddMusicPopupState();
}

class _AddMusicPopupState extends State<AddMusicPopup> {
  late Playlist? playlist = widget.playlist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        TextButton(
            onPressed: () {
              print('TODO: done adding music');
            },
            child: Text('Done')),
      ]),
      body: SingleChildScrollView(
          child: Column(children: [
        // MusicSearchBar(), // TODO
        AddMusicSongList(null),
      ])),
    );
  }
}
