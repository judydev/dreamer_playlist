import 'package:dreamer_playlist/components/add_music_popup.dart';
import 'package:dreamer_playlist/components/edit_playlist_popup.dart';
import 'package:dreamer_playlist/components/helper.dart';
import 'package:dreamer_playlist/components/popup_menu_tile.dart';
import 'package:dreamer_playlist/components/playlist_view_songlist.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:dreamer_playlist/providers/playlist_data_provider.dart';
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
            )), // TODO: hide when first open
        Padding(
          padding: EdgeInsets.all(20),
          child: Icon(Icons.music_video, size: 64),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  Provider.of<PlaylistDataProvider>(context, listen: false)
                      .updatePlaylistFavorite(playlist);
                },
                icon: playlist.loved == 1
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border)),
            IconButton(
                onPressed: () {
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return EditPlaylistPopup(playlist);
                      });
                },
                icon: Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  print('Play current playlist');
                },
                icon: Icon(Icons.play_circle, size: 42)),
            IconButton(
                onPressed: () {
                  print('shuffle play current playlist');
                },
                icon: Icon(Icons.shuffle)),
            IconButton(
              onPressed: () {
                print('playlist more actions');
              },
              icon: PopupMenuButton(
                position: PopupMenuPosition.under,
                child: Icon(Icons.more_vert),
                itemBuilder: (context) => _buildMoreActionsMenu(),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () {
                  showAdaptiveDialog(
                      context: context,
                      builder: ((context) {
                        return AddMusicPopup(playlist);
                      }));
                },
                child: Text('Add from library')),
            TextButton(
                onPressed: () {
                  openFilePicker(context, playlist.id);
                },
                child: Text('Import local file'))
          ],
        ),
        PlaylistViewSongList(playlist),
      ],
    );
  }

  List<PopupMenuItem> _buildMoreActionsMenu() {
    return [
      PopupMenuItem(
        child: PopupMenuTile(
          icon: Icons.playlist_add_rounded,
          title: 'Add to queue',
        ),
        onTap: () {
          print('add current playlist to queue');
        },
      ),
      PopupMenuItem(
        child: PopupMenuTile(
          icon: Icons.copy_rounded,
          title: 'Add to playlist',
        ),
        onTap: () {
          print('add current playlist to another playlist');
        },
      ),
      PopupMenuItem(
        child: PopupMenuTile(
          icon: Icons.delete_outline,
          title: 'Delete playlist',
        ),
        onTap: () {
          showAlertDialogPopup(
              context,
              "Warning",
              Text(
                  "Are you sure you want to delete playlist ${playlist.name}?"),
              [
                displayTextButton(context, "Yes", callback: () {
                  Provider.of<PlaylistDataProvider>(context, listen: false)
                      .deletePlaylist(playlist.id);
                  Provider.of<AppStateDataProvider>(context, listen: false)
                      .updateAppState(AppStateKey.currentPlaylistId, null);
                }),
                displayTextButton(context, "No")
              ]);
        },
      ),
      PopupMenuItem(
        child: PopupMenuTile(
          icon: Icons.ios_share,
          title: 'Share',
        ),
        onTap: () {
          print('Share current playlist');
        },
      ),
    ];
  }
}

