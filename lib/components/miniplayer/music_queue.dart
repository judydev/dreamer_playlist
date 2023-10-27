import 'package:dreamer_playlist/components/song_tile_reorder.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

AudioPlayer _audioPlayer = GetitUtil.audioPlayer;

class MusicQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: queueIndicesNotifier,
        builder: ((context, queueIndices, child) {
          return queueIndices.isNotEmpty
              ? ListView(
                  children: queueIndices
                      .map((songIndex) {
                  return ValueListenableBuilder(
                      valueListenable: currentlyPlayingNotifier,
                      builder: ((context, value, child) {
                        return Container(
                            color: songIndex == _audioPlayer.currentIndex
                              ? Theme.of(context).colorScheme.surfaceTint
                              : null,
                      child: SongTileReorder(
                                songName:
                                    _audioPlayer.sequence?[songIndex].tag.name,
                                songIndex: songIndex));
                      }));
                })
                      .toList())
              : SizedBox.shrink();
        }));
  }
}

void updateQueueIndicesNotifier() {
  queueIndicesNotifier.value = _audioPlayer.effectiveIndices ?? [];
}

bool isEmptyQueue() =>
    // queue.children.isEmpty;
    _audioPlayer.sequence == null || _audioPlayer.sequence!.isEmpty;
