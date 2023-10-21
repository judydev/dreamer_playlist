import 'package:dreamer_playlist/components/helper.dart';
import 'package:dreamer_playlist/components/list_item_view.dart';
import 'package:dreamer_playlist/components/popup_menu_tile.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:dreamer_playlist/providers/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class SongTile extends StatefulWidget {
  final Song song;
  SongTile(this.song);

  @override
  State<StatefulWidget> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  late Song song = widget.song;

  GetIt getIt = GetIt.instance;
  String? currentPlaylistId; // TODO: use GetIt?

  @override
  Widget build(BuildContext context) {
    return ListTileView(
      title: song.name!,
      leadingIcon: Icon(Icons.play_circle_outline),
      trailingIcon: PopupMenuButton(
        position: PopupMenuPosition.under,
        child: Icon(Icons.more_vert),
        itemBuilder: (context) => _buildMoreActionsMenu(),
      ),
      onTapCallback: () {
        print('onTapCallback, clicked on song tile, play this song');

        Provider.of<AppStateDataProvider>(context, listen: false)
            .updateAppState(AppStateKey.currentPlaying, song.id);

        AudioPlayer _player = getIt.get<AudioPlayer>();
        // Go to full player View

        // _player.currentIndex = widget.index;
        _player.play();
      },
    );
  }

  List<PopupMenuItem> _buildMoreActionsMenu() {
    return [
          PopupMenuItem(
            enabled: currentPlaylistId == null ? false : true,
            child: PopupMenuTile(
              icon: Icons.delete_outline,
              title:
                  'Remove from playlist', // only for songs in current playlist
            ),
            onTap: () {
              print('Remove ${song.name} from playlist $currentPlaylistId');
          Provider.of<SongDataProvider>(context, listen: false)
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
              if (currentPlaylistId != null) {
            Provider.of<SongDataProvider>(context, listen: false)
                    .removeSongFromPlaylist(song.id, currentPlaylistId!);
              }
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
                      Provider.of<SongDataProvider>(context, listen: false)
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
    ];
  }
}
