import 'package:dreamer_playlist/components/playlist_edit_songlist.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditPlaylistPopup extends StatefulWidget {
  final Playlist playlist;
  const EditPlaylistPopup(this.playlist);

  @override
  State<EditPlaylistPopup> createState() => _EditPlaylistPopupState();
}

class _EditPlaylistPopupState extends State<EditPlaylistPopup> {
  late Playlist playlist = widget.playlist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Playlist')),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: EditableTextField(
              initialValue: playlist.name!,
              updateValueCallback: (String newName) {
                if (newName.isEmpty) return;
                Provider.of<PlaylistDataProvider>(context, listen: false)
                    .updatePlaylistName(playlist.id, newName);
              },
            ),
          ),
          PlaylistEditSongList(playlist),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${GetitUtil.orderedSongList.length} tracks'))),
        ]),
      ),
    );
  }
}

class EditableTextField extends StatefulWidget {
  final String initialValue;
  final Function updateValueCallback;

  const EditableTextField(
      {required this.initialValue, required this.updateValueCallback});

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  late String initialValue = widget.initialValue;
  late Function updateValueCallback = widget.updateValueCallback;

  bool isEditing = false;
  late String updatedValue = initialValue;
  late String lastValidValue = initialValue;

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return TextField(
        autofocus: true,
        decoration: InputDecoration(border: InputBorder.none),
        controller: TextEditingController(text: updatedValue),
        onChanged: (text) => {updatedValue = text},
        onTapOutside: (event) {
          _validateUpdatedValue();
        },
        onSubmitted: (value) {
          _validateUpdatedValue();
        },
      );
    }

    return Row(
      children: [
        Text(updatedValue),
        isEditing
            ? SizedBox.shrink()
            : IconButton(
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                icon: Icon(Icons.edit),
              )
      ],
    );
  }

  void _validateUpdatedValue() {
    setState(() {
      isEditing = false;
    });

    String trimmed = updatedValue.trim();
    if (trimmed.isNotEmpty) {
      updateValueCallback(trimmed);
      lastValidValue = trimmed;
    } else {
      setState(() {
        updatedValue = lastValidValue;
      });
    }
  }
}
