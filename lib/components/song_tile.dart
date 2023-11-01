import 'package:dreamer_playlist/components/library_view.dart';
import 'package:dreamer_playlist/components/popup_menu_tile.dart';
import 'package:dreamer_playlist/components/select_playlist_popup.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
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
          () {
            print('onTapCallback, clicked on song tile, play this song');
            if (songIndex == null) {
              print('Unknown index');
              return;
            }

            shuffleModeNotifier.value = ShuffleMode.off;
            print('SongTile songIndex = $songIndex');
            play(
                hasShuffleModeChanged: GetitUtil.audioPlayer.shuffleModeEnabled,
                songIndex: songIndex!);
          },
    );
  }
}

List<PopupMenuItem> buildMoreActionsMenu(
    context, Song song, String? currentPlaylistId) {
  return [
    PopupMenuItem(
      // enabled: currentPlaylistId == null ? false : true,
      child: PopupMenuTile(
        icon: Icons.delete_outline,
        title: 'Remove from playlist', // only for songs in current playlist
      ),
      onTap: () {
        print('Remove ${song.title} from playlist ');
        Provider.of<SongDataProvider>(context, listen: false)
            .removeSongFromPlaylist(song.id!, currentPlaylistId!)
            .then(
          (value) {
            // TODO: handle success and error
            print('TODO: SongTile.removeFromPlaylist handle success and error');
          },
        );
      },
    ),
    PopupMenuItem(
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
    PopupMenuItem(
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
    PopupMenuItem(
      child: PopupMenuTile(
        icon: Icons.playlist_add_rounded,
        title: 'Add to queue',
      ),
      onTap: () {
        print('TODO: add current playlist to queue');
        print(song.title);

        GetitUtil.addSongToQueue(song);
        // GetitUtil.audioPlayer.setAudioSource(GetitUtil.queue);
        GetitUtil.print_AudioPlayer_AudioSource_Sequence(
            GetitUtil.queue.sequence);

        // if (GetitUtil.audioPlayer.audioSource == null) {
        //   print('audioSource is null');
        //   // GetitUtil.setQueueFromSonglist([song]);
        //   GetitUtil.setQueueFromSonglist([song]);
        //   GetitUtil.audioPlayer.setAudioSource(GetitUtil.queue);
        //   GetitUtil.print_AudioPlayer_AudioSource_Sequence(
        //       GetitUtil.audioPlayer.sequence!);
        // } else {
        //   print('exisiting sequence');

        //   GetitUtil.print_AudioPlayer_AudioSource_Sequence(
        //       GetitUtil.audioPlayer.sequence ?? []);
        //   GetitUtil.audioPlayer.sequence!
        //       .add(AudioSource.file(song.path!, tag: song));
        //   GetitUtil.print_AudioPlayer_AudioSource_Sequence(
        //       GetitUtil.audioPlayer.sequence!);
        //       GetitUtil.addSongToQueue(song);
        // }
      },
    ),
    PopupMenuItem(
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
    PopupMenuItem(
      child: PopupMenuTile(
        icon: Icons.edit,
        title: 'Rename',
      ),
      onTap: () {
        print('TODO: Rename ${song.title}');
      },
    ),
    PopupMenuItem(
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
