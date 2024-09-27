import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/helpers/popup_menu_tile.dart';
import 'package:dreamer_playlist/components/select_playlist_popup.dart';
import 'package:dreamer_playlist/components/song_tile_select.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditLibraryPopup extends StatefulWidget {
  @override
  State<EditLibraryPopup> createState() => _EditLibraryPopupState();
}

class _EditLibraryPopupState extends State<EditLibraryPopup> {
  late SongDataProvider songDataProvider;
  late Future<List<Song>> _getSongs;

  List<String> selectedSongIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songDataProvider = Provider.of<SongDataProvider>(context);
    if (isFavoriteTab()) {
      _getSongs = songDataProvider.getFavoriteSongs();
    } else {
      _getSongs = songDataProvider.getAllSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Songs')),
        body: FutureBuilderWrapper(_getSongs, (context, snapshot) {
          List<Song> songs = snapshot.data;
          List<String> songIds = songs.map((s) => s.id!).toList();

          if (songs.isNotEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: OverflowBar(
                      alignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                if (selectedSongIds.length == songs.length) {
                                  selectedSongIds = [];
                                } else {
                                  selectedSongIds = songIds;
                                }
                              });
                            },
                            child: selectedSongIds.length == songs.length
                                ? const Text('Unselect All')
                                : const Text('Select All')),
                        PopupMenuButton(
                            position: PopupMenuPosition.under,
                            child: const Text('Actions'),
                            itemBuilder: (context) =>
                                buildMultiSelectMoreActionsMenu(
                                  context,
                                  selectedSongs: selectedSongIds.isEmpty
                                      ? []
                                      : songs
                                          .where((song) => selectedSongIds
                                              .contains(song.id!))
                                          .toList(),
                                ))
                      ]),
                ),
                Expanded(
                    child: ListView(
                        children: List.generate(
                            songs.length,
                            (index) => SongTileSelect(
                                  song: songs[index],
                                  isSelected:
                                      selectedSongIds.contains(songs[index].id),
                                  callback: (Song updatedSong) {
                                    String updatedId = updatedSong.id!;
                                    List<String> oldVal =
                                        List.from(selectedSongIds);
                                    if (oldVal.contains(updatedId)) {
                                      oldVal.remove(updatedId);
                                    } else {
                                      oldVal.add(updatedId);
                                    }

                                    setState(() {
                                      selectedSongIds = oldVal;
                                    });
                                  },
                                ))))
              ],
            );
          } else {
            return Align(
                alignment: Alignment.topCenter,
                child: isFavoriteTab()
                    ? const Text('No favorite songs')
                    : const Text('No songs in library.'));
          }
        }));
  }

  List<PopupMenuItem> buildMultiSelectMoreActionsMenu(context,
      {required List<Song> selectedSongs}) {
    bool favoriteTab = isFavoriteTab();

    return [
      PopupMenuItem<PopupMenuTile>(
        enabled: selectedSongIds.isNotEmpty,
        child: PopupMenuTile(
          icon: Icons.delete_forever_outlined,
          title: 'Delete from library',
        ),
        onTap: () async {
          for (Song song in selectedSongs) {
            await Provider.of<SongDataProvider>(context, listen: false)
                .deleteSong(song);
          }
        },
      ),
      PopupMenuItem<PopupMenuTile>(
        enabled: selectedSongIds.isNotEmpty,
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
      PopupMenuItem<PopupMenuTile>(
        enabled: selectedSongIds.isNotEmpty,
        child: PopupMenuTile(
          icon: Icons.playlist_add,
          title: 'Add to queue',
        ),
        onTap: () async {
          List<MediaItem> mediaItems =
              selectedSongs.map((song) => song.toMediaItem()).toList();
          try {
            await GetitUtil.audioHandler.addQueueItems(mediaItems);
          } catch (e) {
            debugPrint('Error adding to queue from library: $e');
          }
        },
      ),
      PopupMenuItem<PopupMenuTile>(
        enabled: selectedSongIds.isNotEmpty,
        child: PopupMenuTile(
          icon: favoriteTab ? Icons.favorite : Icons.favorite_outline,
          title: favoriteTab ? 'Remove from favorites' : 'Add to favorites',
        ),
        onTap: () {
          Provider.of<SongDataProvider>(context, listen: false)
              .updateSongsFavorite(selectedSongIds, favoriteTab ? 0 : 1);
        },
      ),
    ];
  }
}
