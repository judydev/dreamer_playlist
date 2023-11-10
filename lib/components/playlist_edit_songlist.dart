import 'package:dreamer_playlist/components/popup_menu_tile.dart';
import 'package:dreamer_playlist/components/select_playlist_popup.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/components/song_tile_select.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistEditSongList extends StatefulWidget {
  final Playlist playlist;
  PlaylistEditSongList(this.playlist);

  @override
  State<PlaylistEditSongList> createState() => _PlaylistEditSongListState();
}

class _PlaylistEditSongListState extends State<PlaylistEditSongList> {
  late Playlist playlist = widget.playlist;

  late SongDataProvider songDataProvider;
  late Future<List<Song>> _getSongs;

  List<Song> selectedSongs = [];
  bool selectMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songDataProvider = Provider.of<SongDataProvider>(context);
    _getSongs = songDataProvider.getAllSongsFromPlaylist(playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilderWrapper(_getSongs,
            (context, snapshot) {
          List<Song> songs = snapshot.data;
          if (songs.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                selectMode = !selectMode;
                              });
                            },
                            child: Text(selectMode ? 'Cancel' : 'Select')),
                        selectMode
                            ? PopupMenuButton(
                                position: PopupMenuPosition.under,
                                child: Text('Actions'),
                                itemBuilder: (context) =>
                                    buildMultiSelectMoreActionsMenu(
                                        context, selectedSongs))
                            : PopupMenuButton(
                                child: Text('Sort'),
                                itemBuilder: (context) =>
                                    buildSortMoreActionsMenu(context)),
                      ],
                    )),
                ...songs.map((song) => selectMode
                    ? SongTileSelect(
                        song: song,
                        callback: (updatedSong) {
                          List<Song> oldVal = selectedSongs;
                          if (oldVal.contains(updatedSong)) {
                            oldVal.remove(updatedSong);
                          } else {
                            oldVal.add(updatedSong);
                          }

                          setState(() {
                            selectedSongs = oldVal;
                          });
                        },
                      )
                    : SongTile(
                        song,
                        leadingIcon: Icon(Icons.music_video),
                        trailingIcon: Icon(Icons.menu),
                        disableTap: true,
                      ))
              ], 
            );
          } else {
            return Text("No songs in this playlist.");
          }
        }),
      ],
    );
  }
  
  List<PopupMenuItem> buildMultiSelectMoreActionsMenu(context, List<Song> songs,
      {String? currentPlaylistId, int? songIndex}) {
    return [
      PopupMenuItem<PopupMenuTile>(
        enabled: selectedSongs.isNotEmpty,
        child: PopupMenuTile(
          icon: Icons.delete_outline,
          title: 'Remove from playlist', // only for songs in current playlist
        ),
        onTap: () {
          Provider.of<SongDataProvider>(context, listen: false)
              .removeSongsFromPlaylist(
                  selectedSongs.map((s) => s.playlistSongId!).toList());
        },
      ),
      PopupMenuItem<PopupMenuTile>(
        enabled: selectedSongs.isNotEmpty,
        child: PopupMenuTile(
          icon: Icons.format_list_bulleted_add,
          title: 'Add to playlist',
        ),
        onTap: () {
          showAdaptiveDialog(
            context: context,
            builder: ((context) => SelectPlaylistPopup(selectedSongs)),
          );
        },
      ),
    ];
  }

  List<PopupMenuItem> buildSortMoreActionsMenu(context) {
    return [
      PopupMenuItem<PopupMenuTile>(
        child: PopupMenuTile(
          title: 'Name',
        ),
        onTap: () {
          print('TODO: sort by name');
        },
      ),
      PopupMenuItem<PopupMenuTile>(
        child: PopupMenuTile(
          title: 'Added',
        ),
        onTap: () {
          print('TODO: sort by added');
        },
      ),
    ];
  }
}
