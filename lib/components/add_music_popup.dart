import 'package:dreamer_playlist/components/song_tile_select.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMusicPopup extends StatefulWidget {
  final Playlist playlist;
  AddMusicPopup(this.playlist);

  @override
  State<AddMusicPopup> createState() => _AddMusicPopupState();
}

class _AddMusicPopupState extends State<AddMusicPopup> {
  late Playlist playlist = widget.playlist;

  List<Song> selectedSongs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        TextButton(
            onPressed: () async {
              if (selectedSongs.isNotEmpty) {
                await addSongsToPlaylist(context, selectedSongs, playlist);
              } else {
                Navigator.pop(context, true);
              }
            },
            child: Text('Done')),
      ]),
      body: SingleChildScrollView(
          child: Column(children: [
        // MusicSearchBar(), // TODO
        AddMusicSongList(callback: (selected) {
          selectedSongs = selected;
        }),
      ])),
    );
  }
}

Future<void> addSongsToPlaylist(
    BuildContext context, List<Song> selectedSongs, Playlist playlist) async {
  if (selectedSongs.isEmpty) return;

  Set<String> duplicatedIds =
      await Provider.of<SongDataProvider>(context, listen: false)
          .checkForDuplicateSongsInPlaylist(
              selectedSongs.map((s) => s.id!).toList(), playlist.id);

  for (Song song in selectedSongs) {
    if (duplicatedIds.contains(song.id)) {
      if (!context.mounted) return;
      await showAlertDialogPopup(context,
          title: "Warning",
          content: Text(
              "${song.title} is already in the playlist, are you sure you want to add it again?"),
          actions: [
            displayTextButton(context, "Add", callback: () {
              Provider.of<SongDataProvider>(context, listen: false)
                  .associateSongToPlaylist(song.id!, playlist.id);
            }),
            displayTextButton(context, "Skip")
          ]);
    } else {
      if (!context.mounted) return;
      await Provider.of<SongDataProvider>(context, listen: false)
          .associateSongToPlaylist(song.id!, playlist.id);
    }
  }
  
  if (!context.mounted) return;
  Navigator.pop(context, true);
}

class AddMusicSongList extends StatefulWidget {
  final Function callback;
  AddMusicSongList({required this.callback});

  @override
  State<AddMusicSongList> createState() => _AddMusicSongListState();
}

class _AddMusicSongListState extends State<AddMusicSongList> {
  late Function callback = widget.callback;

  late SongDataProvider songDataProvider;
  late Future<List<Song>> _getSongs;

  List<Song> selectedSongs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songDataProvider = Provider.of<SongDataProvider>(context);
    _getSongs = songDataProvider.getAllSongs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper(_getSongs, (context, snapshot) {
      List<Song> songs = snapshot.data;
      if (songs.isNotEmpty) {
        return Column(
          children: [
            ...songs.map((song) => SongTileSelect(
                  song: song,
                  selectIcon: Icons.add_circle_outline,
                  callback: (updatedSong) {
                    if (selectedSongs.contains(updatedSong)) {
                      selectedSongs.remove(updatedSong);
                    } else {
                      selectedSongs.add(updatedSong);
                    }

                    callback(selectedSongs);
                  },
                ))
          ],
        );
      } else {
        return Center(
          child: Text("No songs in library."),
        );
      }
    });
  }
}
