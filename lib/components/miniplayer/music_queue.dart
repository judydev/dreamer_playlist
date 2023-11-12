import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
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
                  return QueueSongTile(queueIndex: queueIndex);
                }).toList())
              : SizedBox.shrink();
        }));
  }
}

class QueueSongTile extends StatelessWidget {
  final int queueIndex;
  QueueSongTile({required this.queueIndex});

  final AudioPlayer _audioPlayer = GetitUtil.audioHandler.audioPlayer;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: currentIndexNotifier,
        builder: ((context, currentIndex, child) {
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            dismissThresholds: const {DismissDirection.endToStart: 0.6},
            onDismissed: (direction) {
              GetitUtil.audioHandler.removeQueueItemAt(queueIndex);
            },
            background: ColoredBox(
              color: Colors.red,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  // child: Icon(Icons.delete, color: Colors.white),
                  child: Text('Remove'),
                ),
              ),
            ),
            child: Container(
                color: currentIndex != null && queueIndex == currentIndex
                    ? Theme.of(context).colorScheme.primary
                    : null,
                child: child),
          );
        }),
        child: ListTileWrapper(
            title: GetitUtil.audioHandler.queue.value[queueIndex].title,
            leading: Icon(Icons.music_video),
            trailing: Icon(Icons.menu),
            onTap: () async {
              await _audioPlayer.seek(Duration.zero, index: queueIndex);
              await _audioPlayer.play();
            }));
  }
}

void updateQueueIndicesNotifier() {
  queueIndicesNotifier.value =
      GetitUtil.audioHandler.audioPlayer.effectiveIndices ?? [];
}

bool isEmptyQueue() {
  AudioPlayer audioPlayer = GetitUtil.audioHandler.audioPlayer;
  return audioPlayer.sequence != null ? audioPlayer.sequence!.isEmpty : true;
}
