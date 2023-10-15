import 'package:dreamer_app/components/future_builder_wrapper.dart';
import 'package:dreamer_app/models/lyrics.dart';
import 'package:dreamer_app/providers/lyrics_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LyricsView extends StatefulWidget {
  final String? lyricsId;

  LyricsView(this.lyricsId);

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  late String? lyricsId = widget.lyricsId;

  late LyricsDataProvider lyricsDataProvider;
  late Future<Lyrics> _getLyrics;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    lyricsDataProvider = Provider.of<LyricsDataProvider>(context);
    _getLyrics = lyricsDataProvider.getLyricsById(lyricsId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height / 2,
      child: FutureBuilderWrapper(_getLyrics, (context, snapshot) {
        Lyrics? lyrics = snapshot.data;
        return TextField(
          controller: TextEditingController(text: lyrics?.value),
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(
            // filled: true,
            hintText: "Write some lyrics",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // TODO: insert section into database with lyricsId if section does not exist
            lyrics?.value = value;
            Provider.of<LyricsDataProvider>(context, listen: false)
                .addLyrics(lyrics!);
          },
        );
      }),
    );
  }
}
