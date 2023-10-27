import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/components/playlist_tile.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectPlaylistPopup extends StatefulWidget {
  final String songId;
  SelectPlaylistPopup(this.songId);

  @override
  State<SelectPlaylistPopup> createState() => _SelectPlaylistPopupState();
}

class _SelectPlaylistPopupState extends State<SelectPlaylistPopup> {
  late String songId = widget.songId;

  late PlaylistDataProvider playlistDataProvider;
  late Future<List<Playlist>> _getAllPlaylists;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    playlistDataProvider = Provider.of<PlaylistDataProvider>(context);
    _getAllPlaylists = playlistDataProvider.getAllPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(title: Text('Select a playlist')),
        body: FutureBuilderWrapper(
          _getAllPlaylists,
          loadingText: "Loading playlists...",
          (context, snapshot) {
            List<Playlist> playlists = snapshot.data ?? [];
            return Column(
              children: [
                NewPlaylistTile(),
                ...playlists.map((playlist) => ListTileWrapper(
                      title: playlist.name!,
                    leading: Icon(Icons.queue_music),
                    onTap: () {
                        Provider.of<SongDataProvider>(context, listen: false)
                          .checkIfSongExistsInPlaylist(songId, playlist.id)
                          .then((duplicate) {
                        if (duplicate) {
                          showAlertDialogPopup(
                              context,
                              "Warning",
                              Text(
                                  "This song is already in the playlist, are you sure you want to add it again?"),
                              [
                                displayTextButton(context, "Add", callback: () {
                                  Provider.of<SongDataProvider>(context,
                                          listen: false)
                                      .associateSongToPlaylist(
                                          songId, playlist.id)
                                      .then(
                                    (value) {
                                      print(
                                          'TODO: success UI indicating song added');
                                      Navigator.pop(context, true);
                                    },
                                  );
                                }),
                                displayTextButton(context, "Skip")
                              ]);
                        } else {
                          Provider.of<SongDataProvider>(context, listen: false)
                              .associateSongToPlaylist(songId, playlist.id)
                              .then((value) {
                            print('TODO: success UI indicating song added');
                            Navigator.pop(context, true);
                          });
                        }
                      });
                    }
                    ))
              ],
            );
          },
        )));
  }
}
