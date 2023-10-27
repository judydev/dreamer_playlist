import 'package:dreamer_playlist/components/song_tile_reorder.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicQueue extends StatelessWidget {
  final AudioPlayer _audioPlayer = GetitUtil.audioPlayer;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: queueIndicesNotifier,
        builder: ((context, queueIndices, child) {
          return queueIndices.isNotEmpty
              ? ListView(
                  children: queueIndices
                      .map((index) {
                  return Container(
                          color: index == _audioPlayer.currentIndex
                              ? Theme.of(context).colorScheme.surfaceTint
                              : null,
                      child: SongTileReorder(
                          songName: GetitUtil.orderedSongList[index].name!,
                          songIndex: index));
                })
                      .toList())
              : SizedBox.shrink();
        }));
  }
}

List<int> updateQueueIndices() {
  List<int> playingNextIndices = [];
  playingNextIndices = GetitUtil.audioPlayer.effectiveIndices ?? [];
  queueIndicesNotifier.value = playingNextIndices;
  return playingNextIndices;
}
