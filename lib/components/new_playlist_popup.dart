import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewPlaylistPopup extends StatefulWidget {
  final bool? updateAppState;
  NewPlaylistPopup({this.updateAppState});

  @override
  State<NewPlaylistPopup> createState() => _NewPlaylistPopupState();
}

class _NewPlaylistPopupState extends State<NewPlaylistPopup> {
  late final bool? updateAppState = widget.updateAppState;

  final _controller = TextEditingController(text: '');
  String? errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Name",
              errorText: errorText,
            ),
            controller: _controller,
            onChanged: (value) {
              _controller.text = value;
              if (_controller.text.trim().isEmpty) {
                setState(() => errorText = 'Name cannot be empty');
              } else {
                setState(() => errorText = null);
              }
            }),
        ButtonBar(
          alignment: MainAxisAlignment.end,
          children: [
            displayTextButton(context, 'Cancel'),
            TextButton(
              onPressed: () {
                String playlistName = _controller.text.trim();
                if (playlistName.isEmpty) {
                  setState(() => errorText = 'Name cannot be empty');
                } else {
                  createPlaylist(playlistName);
                }
              },
              child: const Text('OK'),
            )
          ],
        )
      ],
    );
  }

  void createPlaylist(String playlistName) async {
    String playlistId =
        await Provider.of<PlaylistDataProvider>(context, listen: false)
            .createPlaylist(playlistName);

    if (updateAppState == true) {
      if (!context.mounted) return;
      await Provider.of<AppStateDataProvider>(context, listen: false)
          .updateAppState(AppStateKey.currentPlaylistId, playlistId);
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}
