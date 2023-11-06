import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SongTileReorder extends StatelessWidget {
  final int queueIndex;
  SongTileReorder({required this.queueIndex});

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
                    ? Theme.of(context).colorScheme.surfaceTint
                    : null,
                child: child),
          );
        }),
        child: ListTileWrapper(
            title: _audioPlayer.sequence?[queueIndex].tag.title,
            leading: Icon(Icons.music_video),
            trailing: Icon(Icons.menu),
            onTap: () async {
              await _audioPlayer.seek(Duration.zero, index: queueIndex);
              await _audioPlayer.play();
            })
    );
  }
}
