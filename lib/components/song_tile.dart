import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/components/popup_menu_tile.dart';
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
  final void Function()? onTapOverride;
  SongTile(this.song,
      {this.currentPlaylistId, this.onTapOverride, this.songIndex});

  @override
  Widget build(BuildContext context) {
    List<PopupMenuItem> moreActionsMenuItems =
        buildMoreActionsMenu(context, song, currentPlaylistId);
    if (currentPlaylistId == null) {
      moreActionsMenuItems.removeAt(0);
    }

    return ListTileWrapper(
      title: song.title!,
      leading: Icon(Icons.play_circle_outline),
      trailing: PopupMenuButton(
        position: PopupMenuPosition.under,
        child: Icon(Icons.more_vert),
        itemBuilder: (context) => moreActionsMenuItems,
      ),
      onTap: onTapOverride ??
          () async {
            print('onTapCallback, clicked on song tile, play this song');
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
}

List<PopupMenuItem> buildMoreActionsMenu(
    context, Song song, String? currentPlaylistId,
    {int? songIndex}) {
  return [
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.delete_outline,
        title: 'Remove from playlist', // only for songs in current playlist
      ),
      onTap: () async {
        print('Remove ${song.title} from playlist ');
        if (song.playlistSongId == null) {
          print(
              'Error when removing ${song.title} from playlist: invalid PlaylistSongId');
          return;
        }
        await Provider.of<SongDataProvider>(context, listen: false)
            .removeSongFromPlaylist(song.playlistSongId!);  
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.delete_forever_outlined,
        title: 'Delete from library',
      ),
      onTap: () {
        Provider.of<SongDataProvider>(context, listen: false)
            .deleteSong(song)
            .then((value) => {
                  // TODO: handle success and error
                  print("SongTile.deleteFromLibrary handle success and error")
                });
        // TODO: verify that song-playlist is removed from db
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.playlist_add,
        title: 'Add to playlist',
      ),
      onTap: () {
        showAdaptiveDialog(
          context: context,
          builder: ((context) {
            return SelectPlaylistPopup(song);
          }),
        );
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.playlist_add_rounded,
        title: 'Play next',
      ),
      onTap: () {
        GetitUtil.audioHandler.addQueueItemAt(
            song.toMediaItem(), currentIndexNotifier.value ?? 0);
      },
    ),
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.playlist_add_rounded,
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
            .updateSongFavorite(song.id!, song.loved ?? 0)
            .then((value) => {
                  print(
                      "TODO: SongTile.updateSongFavorite handle success/error")
                });
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
    PopupMenuItem<PopupMenuTile>(
      child: PopupMenuTile(
        icon: Icons.ios_share,
        title: 'Share',
      ),
      onTap: () {
        print('TODO: Share ${song.title}');
      },
    ),
  ];
}
