import 'package:dreamer_playlist/components/song_tile_reorder.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: queueIndicesNotifier,
        builder: ((context, queueIndices, child) {
          return queueIndices.isNotEmpty
              ? ListView(
                  children: queueIndices
                      .map((queueIndex) {
                  return SongTileReorder(queueIndex: queueIndex);
                }).toList())
              : SizedBox.shrink();
        }));
  }
}

void updateQueueIndicesNotifier() {
  queueIndicesNotifier.value =
      GetitUtil.audioHandler.audioPlayer.effectiveIndices ?? [];
}

bool isEmptyQueue() {
  AudioPlayer audioPlayer = GetitUtil.audioHandler.audioPlayer;
  // print(
  //     'isEmptyQueue? ${audioPlayer.sequence != null ? audioPlayer.sequence!.isEmpty : true}');
  return audioPlayer.sequence != null ? audioPlayer.sequence!.isEmpty : true;
}
