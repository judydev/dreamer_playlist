import 'package:dreamer_playlist/components/add_music_popup.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/components/playlist_tile.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';

class SelectPlaylistPopup extends StatefulWidget {
  final List<Song> songs; // songs to be added to selected playlist
  SelectPlaylistPopup(this.songs);

  @override
  State<SelectPlaylistPopup> createState() => _SelectPlaylistPopupState();
}

class _SelectPlaylistPopupState extends State<SelectPlaylistPopup> {
  late List<Song> songs = widget.songs;

  late Future<List<Playlist>> _getAllPlaylists;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _getAllPlaylists = PlaylistDataService().getAllPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(title: const Text('Select a playlist')),
        body: FutureBuilderWrapper(
          _getAllPlaylists,
          (context, snapshot) {
            List<Playlist> playlists = snapshot.data ?? [];
            return Align(
              alignment: Alignment.topCenter,
              child: ListView(
                children: [
                  NewPlaylistTile(),
                  ...playlists.map((playlist) => ListTileWrapper(
                      title: playlist.name!,
                      leading: const Icon(Icons.queue_music),
                      onTap: () {
                        addSongsToPlaylist(context, songs, playlist);
                      }))
                ],
              ),
            );
          },
        )));
  }
}
