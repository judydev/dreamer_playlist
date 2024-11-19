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
      leading: leadingIcon ?? const Icon(Icons.play_circle_outline),
      trailing: trailingIcon ??
          PopupMenuButton(
        position: PopupMenuPosition.under,
            child: const Icon(Icons.more_vert),
            itemBuilder: (context) =>
                buildMoreActionsMenu(context, song, currentPlaylistId),
      ),
      tileColor: songIndex?.isEven == true ? Theme.of(context).colorScheme.primaryContainer : null,
      onTap: disableTap
          ? null
          : () async {
            if (songIndex == null) {
                debugPrint('Unknown index');
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
          debugPrint(
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Delete "${song.title}" from your library?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<SongDataProvider>(context, listen: false)
                      .deleteSong(song);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
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
        showAlertDialogPopup(
          context,
          title: "Rename Song",
          content: RenameSongPopup(
            initialValue: song.title!,
            onSave: (newTitle) {
              Provider.of<SongDataProvider>(context, listen: false)
                  .updateSongName(song.id!, newTitle);
            },
          ),
        );
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

class RenameSongPopup extends StatefulWidget {
  final String initialValue;
  final Function(String) onSave;

  const RenameSongPopup({
    required this.initialValue,
    required this.onSave,
    super.key,
  });

  @override
  State<RenameSongPopup> createState() => _RenameSongPopupState();
}

class _RenameSongPopupState extends State<RenameSongPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialValue;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: controller,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Song title cannot be empty';
              }
              return null;
            },
            autofocus: true,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    controller.clear();
                  });
                },
              ),
            ),
            onChanged: (_) {},
            onFieldSubmitted: (_) {
              if (_formKey.currentState!.validate() && controller.text.trim().isNotEmpty) {
                widget.onSave(controller.text.trim());
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && controller.text.trim().isNotEmpty) {
                    widget.onSave(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}