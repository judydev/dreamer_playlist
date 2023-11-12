import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/helpers/popup_menu_tile.dart';
import 'package:dreamer_playlist/components/select_playlist_popup.dart';
import 'package:dreamer_playlist/components/song_tile_select.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
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
  late Future<List<int>?> _getPlaylistIndices;

  List<Song> selectedSongs = [];
  bool selectMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songDataProvider = Provider.of<SongDataProvider>(context);
    _getSongs = songDataProvider.getAllSongsFromPlaylist(playlist.id);
    _getPlaylistIndices = songDataProvider.getPlaylistIndices(playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper(_getSongs, (context, snapshot) {
      List<Song> songs = snapshot.data;

      if (songs.isNotEmpty) {
        return Expanded(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                selectMode = !selectMode;
                              });
                            },
                            child: selectMode
                                ? const Text('Cancel')
                                : const Text('Select')),
                        selectMode
                            ? PopupMenuButton(
                                position: PopupMenuPosition.under,
                                child: const Text('Actions'),
                                itemBuilder: (context) =>
                                    buildMultiSelectMoreActionsMenu(
                                        context,
                                        selectedSongs: selectedSongs,
                                        playlistId: playlist.id))
                            : const SizedBox.shrink()
                        // PopupMenuButton(
                        //     child: Text('Sort'),
                        //     itemBuilder: (context) =>
                        //         buildSortMoreActionsMenu(context)),
                      ])),
              Expanded(
                  child: selectMode
                      ? ListView(
                          children: List.generate(
                              songs.length,
                              (index) => SongTileSelect(
                                    song: songs[index],
                                    isSelected:
                                        selectedSongs.contains(songs[index]),
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
                                  )))
                      : FutureBuilderWrapper(_getPlaylistIndices,
                          ((context, snapshot) {
                          List<int> indices = snapshot.data ??
                              List<int>.generate(
                                  GetitUtil.orderedSongList.length,
                                  (int index) => index);

                          return ReorderableListView(
                              onReorder: ((oldIndex, newIndex) {
                                setState(() {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }

                                  try {
                                    final int item = indices.removeAt(oldIndex);
                                    indices.insert(newIndex, item);
                                  } catch (e) {
                                    debugPrint('Error reordering playlist: $e');
                                  }
                                });

                                Provider.of<SongDataProvider>(context,
                                        listen: false)
                                    .updatePlaylistIndices(
                                        playlist.id, indices);
                              }),
                              children: List.generate(
                                  songs.length,
                                  (index) => ListTileWrapper(
                                      title: songs[index].title,
                                      key: Key(index.toString()))));
                        }))),
            ],
          ),
        );
      } else {
        return const Text("No songs in this playlist.");
      }
    });
  }
  
  List<PopupMenuItem> buildMultiSelectMoreActionsMenu(context,
      {required List<Song> selectedSongs, required String playlistId}) {
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
                  selectedSongs.map((s) => s.playlistSongId!).toList(),
                  playlistId);
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
            builder: (context) => SelectPlaylistPopup(selectedSongs),
          );
        },
      ),
      PopupMenuItem<PopupMenuTile>(
        enabled: selectedSongs.isNotEmpty,
        child: PopupMenuTile(
          icon: Icons.playlist_add,
          title: 'Add to queue',
        ),
        onTap: () async {
          List<MediaItem> mediaItems =
              selectedSongs.map((song) => song.toMediaItem()).toList();
          await GetitUtil.audioHandler.addQueueItems(mediaItems);
        },
      ),
    ];
  }

  // List<PopupMenuItem> buildSortMoreActionsMenu(context) {
  //   return [
  //     PopupMenuItem<PopupMenuTile>(
  //       child: PopupMenuTile(
  //         title: 'Name',
  //       ),
  //       onTap: () {
  //         print('TODO: sort by name');
  //       },
  //     ),
  //     PopupMenuItem<PopupMenuTile>(
  //       child: PopupMenuTile(
  //         title: 'Added',
  //       ),
  //       onTap: () {
  //         print('TODO: sort by added');
  //       },
  //     ),
  //   ];
  // }
}
