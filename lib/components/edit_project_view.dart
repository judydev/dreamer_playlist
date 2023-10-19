import 'package:dreamer_playlist/models/playlist.dart';
import 'package:flutter/material.dart';

class EditPlaylistView extends StatefulWidget {
  final Playlist playlist;
  final Function callback;
  EditPlaylistView(this.playlist, this.callback);

  @override
  State<StatefulWidget> createState() => _EditPlaylistViewState();
}

class _EditPlaylistViewState extends State<EditPlaylistView> {
  late Playlist playlist = widget.playlist;
  late String? name = playlist.name;

  @override
  Widget build(BuildContext context) {
    return (SizedBox(
      height: MediaQuery.of(context).size.height / 5,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: "Playlist Name",
            ),
            initialValue: playlist.name,
            onChanged: (value) {
              setState(() {
                name = value;
              });

              playlist.name = value;
              widget.callback(playlist);
            },
          ),
        ],
      ),
    ));
  }
}
