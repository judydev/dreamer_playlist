import 'package:dreamer_playlist/components/helper.dart';
import 'package:dreamer_playlist/components/edit_project_view.dart';
import 'package:dreamer_playlist/components/list_item_view.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:dreamer_playlist/providers/playlist_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatefulWidget {
  final Playlist playlist;
  final int index;
  final Function setCurrentPlaylistCallback;

  PlaylistTile(this.playlist, this.index, this.setCurrentPlaylistCallback);

  @override
  State<StatefulWidget> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  late Playlist playlist;
  late int index;
  late Function setCurrentPlaylistCallback;

  @override
  void initState() {
    super.initState();

    playlist = widget.playlist;
    index = widget.index;
    setCurrentPlaylistCallback = widget.setCurrentPlaylistCallback;

    print(playlist.name);
    print(playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListItemView(
      title: playlist.name!,
      leadingIcon: Icon(Icons.queue_music),
      // trailingIcon: Icon(Icons.arrow_forward_ios_rounded),
      onTapAction: () {
        print('select playlist');
        print(playlist.name);
        print(playlist.id);
        Provider.of<AppStateDataProvider>(context, listen: false)
            .updateLastPlayedAppState(playlist.id);
      },
    );
  }

  editPlaylist(BuildContext context, Playlist playlist, int index) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Playlist"),
          content: EditPlaylistView(playlist, (Playlist updated) {
            playlist = updated;
          }),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () => {
                      // TODO: add empty input validator, or disable OK button when empty
                      if (playlist.name!.isEmpty)
                        {print("name cannot be empty when editing playlist")}
                      else
                        {
                          Provider.of<PlaylistDataProvider>(context,
                                  listen: false)
                              .updatePlaylist(playlist)
                        }
                    })
          ],
        );
      },
    );
  }

  deletePlaylist(context) {
    PlaylistDataProvider playlistDataProvider =
        Provider.of<PlaylistDataProvider>(context, listen: false);

    return showAlertDialogPopup(context, "Warning",
        Text("Are you sure you want to delete playlist ${playlist.name}?"), [
      displayTextButton(context, "Yes", callback: () async {
        await playlistDataProvider.deletePlaylist(playlist.id!);
      }),
      displayTextButton(context, "No")
    ]);
  }
}

class NewPlaylistTile extends StatefulWidget {
  NewPlaylistTile();

  @override
  State<StatefulWidget> createState() => _NewPlaylistTileState();
}

class _NewPlaylistTileState extends State<NewPlaylistTile> {
  @override
  Widget build(BuildContext context) {
    return (SizedBox(
      child: Card(
        shape: BeveledRectangleBorder(),
        child: ListTile(
          leading: Icon(Icons.add),
          title: Text('New Playlist'),
          contentPadding: EdgeInsets.all(10),
          onTap: () => createNewPlaylist(context),
        ),
      ),
    ));
  }

  createNewPlaylist(context) {
    Playlist playlist = Playlist();

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Playlist"),
          content: EditPlaylistView(playlist, (Playlist updated) {
            playlist = updated;
          }),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () async => {
                      print(playlist.name),
                      // TODO: add empty input validator, or disable OK button when empty
                      if (playlist.name == null)
                        {
                          print("name cannot be empty"),
                        }
                      else
                        {
                          await Provider.of<PlaylistDataProvider>(context,
                                  listen: false)
                              .addPlaylist(playlist)
                        }
                    })
          ],
        );
      },
    );
  }
}
