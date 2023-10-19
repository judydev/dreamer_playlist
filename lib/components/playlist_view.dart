import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/helper.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:dreamer_playlist/providers/playlist_song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

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
        playlistSongDataProvider.getAllSongsFromPlaylist(playlist.id!);
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
                    .updateLastPlayedAppState(null);
              },
            )),
        IconButton(
            icon: Icon(Icons.add_box_outlined),
            tooltip: "Add Music",
            onPressed: () {
              _openFilePicker();
            }),
        FutureBuilderWrapper(_getPlaylistSongs, loadingText: 'Loading songs...',
            (context, snapshot) {
          List<Song> songs = snapshot.data;
          print(songs);
          if (songs.isNotEmpty) {
            return Column(
              children: [...songs.map((song) => SongTile(song))],
            );
          } else {
            return Text("No songs in this playlist.");
          }
        })
      ],
    );
  }

  void _openFilePicker() {
    FilePicker.platform.pickFiles().then((selectedFile) => {
          if (selectedFile != null)
            {
              for (final file in selectedFile.files)
                {
                  if (acceptedAudioExtensions.contains(file.extension))
                    {
                      // add song to db
                      // copy song file to storage

                      // callback(file);
                    }
                  else
                    {
                      showAlertDialogPopup(
                          context,
                          "Warning",
                          Text("The file you selected is not an audio file."),
                          [displayTextButton(context, "OK")])
                    }
                }
            }
        });
  }
}

List<String> acceptedAudioExtensions = List.unmodifiable(["m4a", "mp3", "wav"]);
