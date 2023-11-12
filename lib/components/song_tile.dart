import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/helpers/popup_menu_tile.dart';
import 'package:dreamer_playlist/components/select_playlist_popup.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final int? songIndex;
  final String? currentPlaylistId;
  final bool disableTap;
  final Icon? leadingIcon;
  final Icon? trailingIcon;

  SongTile(this.song,
      {super.key,
      this.songIndex,
      this.currentPlaylistId,
      this.disableTap = false,
      this.leadingIcon,
      this.trailingIcon});

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
      title: song.title!,
      leading: leadingIcon ?? Icon(Icons.play_circle_outline),
      trailing: trailingIcon ??
          PopupMenuButton(
        position: PopupMenuPosition.under,
        child: Icon(Icons.more_vert),
            itemBuilder: (context) =>
                buildMoreActionsMenu(context, song, currentPlaylistId),
      ),
      onTap: disableTap
          ? null
          : () async {
            if (songIndex == null) {
              print('Unknown index');
              return;
            }

            await GetitUtil.audioHandler
                .resetQueueFromSonglist(GetitUtil.orderedSongList);
           
            updateQueueIndicesNotifier();
            currentIndexNotifier.value = songIndex;
            await Future.delayed(Duration(milliseconds: 10), () => {}); // TODO
            await GetitUtil.audioHandler.skipToQueueItem(songIndex!);
          },
    );
  }
  
  List<PopupMenuItem> buildMoreActionsMenu(
    context, Song song, String? currentPlaylistId,
    {int? songIndex}) {
      
    List<PopupMenuItem> menuItems = [
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.delete_outline,
        title: 'Remove from playlist', // only for songs in current playlist
      ),
        onTap: () async {
        if (song.playlistSongId == null) {
          print(
              'Error when removing ${song.title} from playlist: invalid PlaylistSongId');
          } else {
            await Provider.of<SongDataProvider>(context, listen: false)
                .removeSongsFromPlaylist(
                    [song.playlistSongId!], currentPlaylistId!);
          }
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.delete_forever_outlined,
        title: 'Delete from library',
      ),
      onTap: () {
        Provider.of<SongDataProvider>(context, listen: false)
              .deleteSong(song);
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
          icon: Icons.format_list_bulleted_add,
        title: 'Add to playlist',
      ),
      onTap: () {
        showAdaptiveDialog(
          context: context,
          builder: ((context) => SelectPlaylistPopup([song])),
        );
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
          icon: Icons.playlist_play,
        title: 'Play next',
      ),
      onTap: () {
        GetitUtil.audioHandler.addQueueItemAt(
            song.toMediaItem(), currentIndexNotifier.value ?? 0);
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
          icon: Icons.playlist_add,
        title: 'Add to queue',
      ),
      onTap: () {
        GetitUtil.audioHandler.addQueueItem(song.toMediaItem());
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: song.loved == 1 ? Icons.favorite : Icons.favorite_border,
        title: song.loved == 1 ? 'Loved' : 'Love',
      ),
      onTap: () {
        print('Add ${song.title} to Favorite');
        Provider.of<SongDataProvider>(context, listen: false)
              .updateSongFavorite(song.id!, song.loved ?? 0);
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.edit,
        title: 'Rename',
      ),
      onTap: () {
        String? updatedSongTitle;
        showAlertDialogPopup(context,
            title: "Rename Song",
            content: TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: song.title,
              ),
              onChanged: (value) {
                updatedSongTitle = value;
              },
            ),
            actions: [
              displayTextButton(context, "Cancel"),
              displayTextButton(context, "OK", callback: () {
                if (updatedSongTitle == null) return;
                Provider.of<SongDataProvider>(context, listen: false)
                      .updateSongName(song.id!, updatedSongTitle!);
              })
            ]);
      },
    ),
    // PopupMenuItem<PopupMenuTile>(
    //   child: PopupMenuTile(
    //     icon: Icons.ios_share,
    //     title: 'Share',
    //   ),
    //   onTap: () {
    //     print('TODO: Share ${song.title}');
    //   },
    // ),
    ];

    if (currentPlaylistId == null) {
      menuItems.removeAt(0);
    }

    return menuItems;
  }
}
