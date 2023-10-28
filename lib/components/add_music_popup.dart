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
            onPressed: () {
              if (selectedSongs.isNotEmpty) {
                addSongsToPlaylist(context, selectedSongs, playlist);
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

void addSongsToPlaylist(
    BuildContext context, List<Song> selectedSongs, Playlist playlist) {
  int duplicates = 0;
  for (Song song in selectedSongs) {
    Provider.of<SongDataProvider>(context, listen: false)
        .checkIfSongExistsInPlaylist(song.id, playlist.id)
        .then((duplicate) {
      if (duplicate) {
        duplicates += 1;
        showAlertDialogPopup(
            context,
            "Warning",
            Text(
                "${song.name} is already in the playlist, are you sure you want to add it again?"),
            [
              displayTextButton(context, "Add", callback: () {
                duplicates -= 1;
                Provider.of<SongDataProvider>(context, listen: false)
                    .associateSongToPlaylist(song.id, playlist.id)
                    .then(
                  (value) {
                    print('TODO: success UI indicating song added');
                    if (duplicates == 0) {
                      Navigator.pop(context, true);
                    }
                  },
                );
              }),
              displayTextButton(context, "Skip", callback: () {
                duplicates -= 1;

                if (duplicates == 0) {
                  Navigator.pop(context, true);
                }
              })
            ]);
      } else {
        Provider.of<SongDataProvider>(context, listen: false)
            .associateSongToPlaylist(song.id, playlist.id)
            .then((value) {
          print('TODO: success UI indicating song ${song.name} added');
          if (duplicates == 0) {
            Navigator.pop(context, true);
          }
        });
      }
    });
  }
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
    return Column(
      children: [
        FutureBuilderWrapper(_getSongs, (context, snapshot) {
          List<Song> songs = snapshot.data;
          if (songs.isNotEmpty) {
            return Column(
              children: [
                ...songs.map((song) => _SongTileForAddMusic(
                      song: song,
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
            return Text("No songs.");
          }
        }),
      ],
    );
  }
}

class _SongTileForAddMusic extends StatefulWidget {
  final Song song;
  final Function callback;
  _SongTileForAddMusic({required this.song, required this.callback});

  @override
  State<_SongTileForAddMusic> createState() => _SongTileForAddMusicState();
}

class _SongTileForAddMusicState extends State<_SongTileForAddMusic> {
  late Song song = widget.song;
  late Function callback = widget.callback;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
        title: song.name!,
        leading: Icon(Icons.play_circle_outline),
        trailing: IconButton(
          icon: isSelected
              ? Icon(Icons.check_circle)
              : Icon(Icons.add_circle_outline),
          onPressed: () {
            setState(() {
              isSelected = !isSelected;
            });

            callback(song);
          },
        ),
        onTap: null);
  }
}
