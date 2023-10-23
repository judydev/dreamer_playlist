import 'package:dreamer_playlist/components/list_item_view.dart';
import 'package:dreamer_playlist/components/popup_menu_tile.dart';
import 'package:dreamer_playlist/components/select_playlist_popup.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlaylistSongTile extends StatefulWidget {
  final Song song;
  final String? currentPlaylistId;
  PlaylistSongTile(this.song, {this.currentPlaylistId});

  @override
  State<StatefulWidget> createState() => _PlaylistSongTileState();
}

class _PlaylistSongTileState extends State<PlaylistSongTile> {
  late Song song = widget.song;
  late String? currentPlaylistId = widget.currentPlaylistId;

  GetIt getIt = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    print(currentPlaylistId);
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
        // enabled: currentPlaylistId == null ? false : true,
        child: PopupMenuTile(
          icon: Icons.delete_outline,
          title: 'Remove from playlist', // only for songs in current playlist
        ),
        onTap: () {
          print('Remove ${song.name} from playlist ');
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
        onTap: () async {
          print('Add ${song.name} to playlist $currentPlaylistId');
          showAdaptiveDialog(
            context: context,
            builder: ((context) {
              return SelectPlaylistPopup(song.id);
            }),
          );
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
