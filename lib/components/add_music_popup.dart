import 'package:dreamer_playlist/components/song_tile_select.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add from library'), actions: [
        TextButton(
            onPressed: () async {
              if (selectedSongs.isNotEmpty) {
                await addSongsToPlaylist(context, selectedSongs, playlist);
              } else {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Done')),
      ]),
      body: FutureBuilderWrapper(_getSongs, (context, snapshot) {
        List<Song> songs = snapshot.data;
        if (songs.isNotEmpty) {
          return Column(
            children: [
              // MusicSearchBar(), // TODO
              OverflowBar(alignment: MainAxisAlignment.start, children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        if (selectedSongs.length == songs.length) {
                          selectedSongs = [];
                        } else {
                          selectedSongs = songs;
                        }
                      });
                    },
                    child: selectedSongs.length == songs.length
                        ? const Text('Unselect All')
                        : const Text('Select All')),
              ]),
              Expanded(
                child: ListView(
                    children: songs
                        .map((song) => SongTileSelect(
                              song: song,
                              selectIcon: const Icon(Icons.add_circle_outline),
                              isSelected: selectedSongs.contains(song),
                              callback: (updatedSong) {
                                List<Song> oldSelected =
                                    List.from(selectedSongs);
                                if (oldSelected.contains(updatedSong)) {
                                  oldSelected.remove(updatedSong);
                                } else {
                                  oldSelected.add(updatedSong);
                                }

                                setState(() {
                                  selectedSongs = oldSelected;
                                });
                              },
                            ))
                        .toList()),
              ),
            ],
          );
        } else {
          return Align(
            alignment: Alignment.topCenter,
            child: const Text("No songs in library."),
          );
        }
      }),
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
