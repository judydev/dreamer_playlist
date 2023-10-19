import 'package:dreamer_playlist/components/edit_playlist_view.dart';
import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/helper.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:dreamer_playlist/providers/playlist_data_provider.dart';
import 'package:dreamer_playlist/providers/playlist_song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistView extends StatefulWidget {
  final Playlist playlist;

  PlaylistView({required this.playlist});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  late Playlist playlist = widget.playlist;

  late PlaylistSongDataProvider playlistSongDataProvider;
  late Future<List<Song>> _getPlaylistSongs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    playlistSongDataProvider = Provider.of<PlaylistSongDataProvider>(context);
    _getPlaylistSongs =
        playlistSongDataProvider.getAllSongsFromPlaylist(playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppBar(
            title: Text(playlist.name!),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Provider.of<AppStateDataProvider>(context, listen: false)
                    .updateAppState(AppStateKey.currentPlaylistId, null);
              },
            )),
        Row(
          children: [
            IconButton(
                icon: Icon(Icons.add_box_outlined),
                tooltip: "Add Music",
                onPressed: () {
                  openFilePicker(context, playlist.id);
                }),
            IconButton(
                icon: Icon(Icons.edit),
                tooltip: "Edit Playlist",
                onPressed: () {
                  showAdaptiveDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Edit Playlist"),
                        content: EditPlaylistView(playlist, (Playlist updated) {
                          playlist = updated;
                        }),
                        actions: [
                          displayTextButton(context, "Cancel"),
                          displayTextButton(context, "OK",
                              callback: () => {
                                    // TODO: add empty input validator, or disable OK button when empty
                                    if (playlist.name == null)
                                      {
                                        print("name cannot be empty"),
                                      }
                                    else
                                      {
                                        Provider.of<PlaylistDataProvider>(
                                                context,
                                                listen: false)
                                            .updatePlaylistName(
                                                playlist.id, playlist.name!)
                                      }
                                  })
                        ],
                      );
                    },
                  );
                }),
            IconButton(
                icon: Icon(Icons.delete_outline),
                tooltip: "Delete Playlist",
                onPressed: () {
                  showAlertDialogPopup(
                      context,
                      "Warning",
                      Text(
                          "Are you sure you want to delete playlist ${playlist.name}?"),
                      [
                        displayTextButton(context, "Yes", callback: () {
                          Provider.of<PlaylistDataProvider>(context,
                                  listen: false)
                              .deletePlaylist(playlist.id);
                          Provider.of<AppStateDataProvider>(context,
                                  listen: false)
                              .updateAppState(
                                  AppStateKey.currentPlaylistId, null);
                        }),
                        displayTextButton(context, "No")
                      ]);
                }),
          ],
        ),
        FutureBuilderWrapper(_getPlaylistSongs, loadingText: 'Loading songs...',
            (context, snapshot) {
          List<Song> songs = snapshot.data;
          if (songs.isNotEmpty) {
            return Column(
              children: [
                ...songs.map((song) => SongTile(
                      song,
                      currentPlaylistId: playlist.id,
                    ))
              ],
            );
          } else {
            return Text("No songs in this playlist.");
          }
        })
      ],
    );
  }
}

