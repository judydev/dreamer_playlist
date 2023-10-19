import 'package:dreamer_playlist/components/helper.dart';
import 'package:dreamer_playlist/components/list_item_view.dart';
import 'package:dreamer_playlist/components/popup_menu_tile.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/playlist_song_data_provider.dart';
import 'package:dreamer_playlist/providers/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongTile extends StatefulWidget {
  final Song song;
  final String? currentPlaylistId;
  SongTile(this.song, {this.currentPlaylistId});

  @override
  State<StatefulWidget> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  late Song song = widget.song;
  late String? currentPlaylistId = widget.currentPlaylistId;

  @override
  Widget build(BuildContext context) {
    return ListItemView(
      title: song.name!,
      leadingIcon: Icon(Icons.music_video),
      trailingIcon: PopupMenuButton(
        position: PopupMenuPosition.under,
        child: Icon(Icons.more_horiz),
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: currentPlaylistId == null ? false : true,
            child: PopupMenuTile(
              icon: Icons.delete_outline,
              title:
                  'Remove from playlist', // only for songs in current playlist
            ),
            onTap: () {
              print('Remove ${song.name} from playlist $currentPlaylistId');
              Provider.of<PlaylistSongDataProvider>(context, listen: false)
                  .removeSongFromPlaylist(song.id, currentPlaylistId!);
            },
          ),
          PopupMenuItem(
            child: PopupMenuTile(
              icon: Icons.delete_forever_outlined,
              title: 'Delete from library',
            ),
            onTap: () {
              print('Delete ${song.name} from library');
              Provider.of<PlaylistSongDataProvider>(context, listen: false)
                  .removeSongFromPlaylist(song.id, currentPlaylistId!);
              Provider.of<SongDataProvider>(context, listen: false)
                  .deleteSong(song);
            },
          ),
          PopupMenuItem(
            child: PopupMenuTile(
              icon: Icons.playlist_add,
              title: 'Add to playlist',
            ),
            onTap: () {
              print('Add ${song.name} to playlist $currentPlaylistId');

              if (currentPlaylistId == null) {
                // TODO: popup to select a playlistId
              } else {
                // TODO: duplicate check, if song is already associated to the playlist
                bool duplicate = true;
                if (duplicate) {
                  showAlertDialogPopup(
                      context,
                      "Warning",
                      Text(
                          "This song is already in the playlist, are you sure you want to add it again?"),
                      [
                        displayTextButton(context, "Add", callback: () {
                          Provider.of<PlaylistSongDataProvider>(context,
                                  listen: false)
                              .associateSongToPlaylist(
                                  song.id, currentPlaylistId!);
                        }),
                        displayTextButton(context, "Skip")
                      ]);
                  // } else {
                  //   Provider.of<PlaylistSongDataProvider>(context,
                  //           listen: false)
                  //       .associateSongToPlaylist(
                  //           song.id, currentPlaylistId!);
                }
              }
            },
          ),
          PopupMenuItem(
            child: PopupMenuTile(
              icon: song.loved == 1 ? Icons.favorite : Icons.favorite_border,
              title: song.loved == 1 ? 'Loved' : 'Love',
            ),
            onTap: () {
              print('Add ${song.name} to Favorite');
              Provider.of<SongDataProvider>(context, listen: false)
                  .updateSongFavorite(song.id, song.loved ?? 0);
            },
          ),
          PopupMenuItem(
            child: PopupMenuTile(
              icon: Icons.edit,
              title: 'Rename',
            ),
            onTap: () {
              print('Rename ${song.name}');
            },
          ),
          PopupMenuItem(
            child: PopupMenuTile(
              icon: Icons.ios_share,
              title: 'Share',
            ),
            onTap: () {
              print('Share ${song.name}');
            },
          ),
        ],
      ),
      onTapCallback: () {
        print('onTapCallback, clicked on song tile');
        print(song.name);
        print(song.id);
      },
    );
  }
}
