import 'package:flutter/material.dart';

class LyricsView extends StatefulWidget {
  final String lyrics;
  LyricsView(this.lyrics);

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  String lyrics = "";
  List<double> timestamps = [];

  @override
  void initState() {
    super.initState();
    lyrics = widget.lyrics;
  }

  @override
  Widget build(BuildContext context) {
    List<String> lines = lyrics.split("\n");

    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Text("Lyrics:"),
        for (String line in lines) Text(line),
      ],
    );
  }
}
