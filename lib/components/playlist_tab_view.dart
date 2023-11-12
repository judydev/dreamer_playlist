import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/components/add_music_popup.dart';
import 'package:dreamer_playlist/components/edit_playlist_popup.dart';
import 'package:dreamer_playlist/components/library_tab_view.dart';
import 'package:dreamer_playlist/components/select_playlist_popup.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/helpers/popup_menu_tile.dart';
import 'package:dreamer_playlist/components/songlist_view.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistTabView extends StatelessWidget {
  final Playlist playlist;
  PlaylistTabView({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppBar(
            title: Text(playlist.name!),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                if (isPlaylistsTab()) {
                Provider.of<AppStateDataProvider>(context, listen: false)
                    .updateAppState(AppStateKey.currentPlaylistId, null);
                }
                if (isFavoriteTab()) {
                  selectedFavoritePlaylistNotifier.value = null;
                }
              },
            )),
        // Padding(
        //   padding: const EdgeInsets.all(20),
        //   child: const Icon(Icons.music_video, size: 64),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Favorite
            IconButton(
                onPressed: () {
                  Provider.of<PlaylistDataProvider>(context, listen: false)
                      .updatePlaylistFavorite(playlist);                      
                  if (isFavoriteTab()) {
                    selectedFavoritePlaylistNotifier.value = null;
                  }
                },
                icon: playlist.loved == 1
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_border)),
            // Edit
            IconButton(
                onPressed: () {
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) => EditPlaylistPopup(playlist));
                },
                tooltip: 'Edit',
                icon: const Icon(Icons.edit)),
            // Play
            IconButton(
                onPressed: () async {
                  await play(
                      hasShuffleModeChanged: GetitUtil
                          .audioHandler.audioPlayer.shuffleModeEnabled);
                },
                tooltip: 'Play',
                icon: const Icon(Icons.play_circle, size: 42)),
            // Shuffle
            IconButton(
                onPressed: () async {
                  await shufflePlay();
                },
                tooltip: 'Shuffle Play',
                icon: const Icon(Icons.shuffle)),
            // More Actions
            PopupMenuButton(
                position: PopupMenuPosition.under,
              child: const Icon(Icons.more_vert),
              itemBuilder: (context) => _buildPlaylistMoreActionsMenu(context),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: TextButton(
                onPressed: () {
                  showAdaptiveDialog(
                      context: context,
                        builder: ((context) => AddMusicPopup(playlist)));
                },
                  child: const Text('Add from library')),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: TextButton(
                  onPressed: () {
                    openFilePicker(context, playlist.id);
                  },
                  child: const Text('Import local file')),
            ),
          ],
        ),
        SongListView(playlist: playlist),
      ],
    );
  }

  List<PopupMenuItem> _buildPlaylistMoreActionsMenu(context) {
    return [
      PopupMenuItem(
        enabled: GetitUtil.orderedSongList.isNotEmpty,
        child: PopupMenuTile(
          icon: Icons.playlist_add_rounded,
          title: 'Add to queue',
        ),
        onTap: () {
          List<MediaItem> mediaItems = GetitUtil.orderedSongList
              .map((song) => song.toMediaItem())
              .toList();
          GetitUtil.audioHandler.addQueueItems(mediaItems);
        },
      ),
      PopupMenuItem(
        enabled: GetitUtil.orderedSongList.isNotEmpty,
        child: PopupMenuTile(
          icon: Icons.copy_rounded,
          title: 'Add to playlist',
        ),
        onTap: () {
          showAdaptiveDialog(
            context: context,
            builder: ((context) =>
                SelectPlaylistPopup(GetitUtil.orderedSongList)),
          );
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
              title: "Warning",
              content: Text(
                  "Are you sure you want to delete playlist ${playlist.name}?"),
              actions: [
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
      // TODO: future work
      // PopupMenuItem(
      //   child: PopupMenuTile(
      //     icon: Icons.ios_share,
      //     title: 'Share',
      //   ),
      //   onTap: () {
      //     print('TODO: Share current playlist');
      //   },
      // ),
    ];
  }
}

