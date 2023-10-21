import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/song_data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

TextButton displayTextButton(BuildContext context, String title,
    {Function? callback}) {
  return (TextButton(
      onPressed: () {
      if (callback != null) {
        callback();
      }
      Navigator.of(context).pop();
    },
      child: Text(title)
  ));
}

Future<void> showAlertDialogPopup(
    context, String title, Widget? content, List<Widget>? actions) async {
  return showAdaptiveDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: actions,
      );
    },
  );
}

List<String> acceptedAudioExtensions =
    List.unmodifiable(["m4a", "mp3", "wav", "aiff"]);

void openFilePicker(context, String? playlistId) {
  Song song;
  FilePicker.platform.pickFiles().then((selectedFile) async => {
        if (selectedFile != null)
          {
            for (final file in selectedFile.files)
              {
                if (acceptedAudioExtensions.contains(file.extension))
                  {
                    song = await Provider.of<SongDataProvider>(context,
                            listen: false)
                        .addSong(file),
                    if (playlistId != null)
                      {
                        await Provider.of<SongDataProvider>(context,
                                listen: false)
                            .associateSongToPlaylist(song.id, playlistId),
                      },
                  }
                else
                  {
                    showAlertDialogPopup(
                        context,
                        "Warning",
                        Text("The file you selected is not an audio file."),
                        [displayTextButton(context, "OK")])
                  }
              }
          }
      });
}
