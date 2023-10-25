import 'package:dreamer_playlist/components/song_tile_reorder.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AudioPlayer audioPlayer = GetitUtil.audioPlayer;

    return ValueListenableBuilder(
      valueListenable: effectiveIndicesNotifier,
      builder:
          (BuildContext context, List<int>? effectiveIndices,
              Widget? child) =>
          effectiveIndices != null
                  ? ListView(
                  children: effectiveIndices
                      .map((index) => Container(
                              color: index == audioPlayer.currentIndex
                                  ? Theme.of(context).colorScheme.surfaceTint
                                  : null,
                          child: SongTileReorder(
                              songName: audioPlayer.sequence?[index].tag,
                              songIndex: index)))
                          .toList())
                  : SizedBox.shrink(),
    );
  }
}
