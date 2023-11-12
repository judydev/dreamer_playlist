import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
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
    context,
    {required String title, Widget? content, List<Widget>? actions}) async {
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

Future<bool> openFilePicker(context, String? playlistId) async {
  FilePickerResult? selected = await FilePicker.platform.pickFiles(
    allowedExtensions: acceptedAudioExtensions,
    allowMultiple: true,
  );

  if (selected != null) {
    for (final file in selected.files) {
      if (acceptedAudioExtensions.contains(file.extension)) {
        Song song = await Provider.of<SongDataProvider>(context, listen: false)
            .addSong(file);
        if (playlistId != null) {
          await Provider.of<SongDataProvider>(context, listen: false)
              .associateSongToPlaylist(song.id!, playlistId);
        }
      } else {
        showAlertDialogPopup(context,
            title: "Warning",
            content: const Text("The file you selected is not an audio file."),
            actions: [displayTextButton(context, "OK")]);
      }
    }
  }

  return true;
}

class ListTileWrapper extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final String? title;
  final void Function()? onTap;

  ListTileWrapper(
      {super.key, this.leading, this.trailing, this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // custom styles
      shape: Border(
          bottom: BorderSide(
        color: Colors.black54,
      )),
      contentPadding: const EdgeInsets.all(10),
      // parameters for ListTile
      title: Text(title ?? ""),
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }
}


class FutureBuilderWrapper extends StatelessWidget {
  final Future future;
  final Widget Function(BuildContext, AsyncSnapshot<dynamic>) buildFunction;
  final String? loadingText;

  FutureBuilderWrapper(this.future, this.buildFunction, {this.loadingText});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          if (loadingText != null) {
            return Text(loadingText!);
          } else {
            return const SizedBox.shrink();
          }
        }
        if (snapshot.hasError) {
          return ErrorView(snapshot.error.toString());
        } else {
          return buildFunction(context, snapshot);
        }
      },
    );
  }
}

class ErrorView extends StatelessWidget {
  final String errorMessage;
  ErrorView(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Error: $errorMessage'),
          ),
        ]);
  }
}
