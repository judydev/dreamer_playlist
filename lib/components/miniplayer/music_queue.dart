import 'package:dreamer_playlist/components/song_tile_reorder.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AudioPlayer audioPlayer = GetitUtil.audioPlayer;
    return ValueListenableBuilder(
      valueListenable: GetitUtil.effectiveIndicesNotifier,
      builder:
          (BuildContext context, List<int>? effectiveIndices,
              Widget? child) =>
          effectiveIndices != null
                  ? ListView(
                      children: audioPlayer.effectiveIndices!
                          .map((index) => Container(
                              color: index == audioPlayer.currentIndex
                                  ? Theme.of(context).colorScheme.surfaceTint
                                  : null,
                          child: SongTileReorder(
                              audioPlayer.audioSource?.sequence[index].tag)))
                          .toList())
                  : SizedBox.shrink(),
    );
  }
}
