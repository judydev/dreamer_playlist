import 'package:flutter/material.dart';

class LyricsView extends StatefulWidget {
  final String lyrics;
  final bool isEditing;
  LyricsView(this.lyrics, this.isEditing);

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  String lyrics = "";
  late bool isEditing;
  List<double> timestamps = [];

  @override
  void initState() {
    super.initState();
    lyrics = widget.lyrics;
  }

  @override
  Widget build(BuildContext context) {
    // List<String> lines = lyrics.split("\n");
    isEditing = widget.isEditing;
    if (!isEditing) {
      return Text(lyrics);
    } else {
      return TextFormField(
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        keyboardType: TextInputType.multiline,
        maxLines: null,
        initialValue: lyrics,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Add lyrics here',
        ),
        onChanged: (value) {
          // auto-save lyrcis to local storage
          // LocalStorage.getlocalFile();
          setState(() {
            lyrics = value;
          });
        },
      );
    }
  }
}
