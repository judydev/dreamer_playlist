// Modified from: https://github.com/dxvid-pts/miniplayer/blob/master/example/lib/widgets/player.dart

import 'package:dreamer_playlist/components/miniplayer/miniplayer.dart';
import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/helpers/getx_helper.dart';
import 'package:flutter/material.dart';

const double playerMinHeight = 70;
const miniplayerPercentageDeclaration = 0.2;

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController controller = MiniplayerController();

class ExpandablePlayer extends StatefulWidget {
  final Song song;
  const ExpandablePlayer(this.song);

  @override
  State<StatefulWidget> createState() => _ExpandablePlayerState();
}

class _ExpandablePlayerState extends State<ExpandablePlayer> {
  late Song song = widget.song;
  bool playing = GetUtil.audioPlayer.playing;

  @override
  Widget build(BuildContext context) {
    double playerMaxHeight = MediaQuery.of(context).size.height;
    return Miniplayer(
      valueNotifier: playerExpandProgress,
      minHeight: playerMinHeight,
      maxHeight: playerMaxHeight,
      controller: controller,
      elevation: 4,
      onDismissed: () => GetUtil.currentlyPlaying.value = null,
      curve: Curves.easeOut,
      builder: (height, percentage) {
        final bool miniplayer = percentage < miniplayerPercentageDeclaration;

        final songName = Text(song.name!);
        final progressIndicator = LinearProgressIndicator(value: 0.3);

        IconButton buttonPlayPrevious = IconButton(
            onPressed: onPressPlayPrev, icon: Icon(Icons.skip_previous));
        IconButton buttonPlayNext =
            IconButton(onPressed: onPressPlayNext, icon: Icon(Icons.skip_next));
        IconButton buttonPlayPause = IconButton(
          icon: playing
              ? Icon(miniplayer ? Icons.pause : Icons.pause_circle_filled)
              : Icon(miniplayer ? Icons.play_arrow : Icons.play_circle),
          iconSize: miniplayer ? 25 : 50,
          onPressed: onPressPlayPause,
        );

        if (!miniplayer) {
          // Full Screen Player
          var percentageExpandedPlayer = percentageFromValueInRange(
              min: playerMaxHeight * miniplayerPercentageDeclaration +
                  playerMinHeight,
              max: playerMaxHeight,
              value: height);
          if (percentageExpandedPlayer < 0) percentageExpandedPlayer = 0;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  child: Opacity(
                    opacity: percentageExpandedPlayer,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(child: songName),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buttonPlayPrevious,
                              buttonPlayPause,
                              buttonPlayNext,
                            ],
                          ),
                        ),
                        Flexible(child: progressIndicator),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // Mini Player
        final percentageMiniplayer = percentageFromValueInRange(
            min: playerMinHeight,
            max: playerMaxHeight * miniplayerPercentageDeclaration +
                playerMinHeight,
            value: height);

        final elementOpacity = 1 - 1 * percentageMiniplayer;
        final progressIndicatorHeight = 4 - 4 * percentageMiniplayer;

        return Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.music_note)),
                  Flexible(
                      fit: FlexFit.loose,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          song.name!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                  Row(
                    children: [
                      buttonPlayPrevious,
                      buttonPlayPause,
                      buttonPlayNext,
                    ],
                  )
                ],
              ),
            )),
            SizedBox(
              height: progressIndicatorHeight,
              child: Opacity(
                opacity: elementOpacity,
                child: progressIndicator,
              ),
            ),
          ],
        );
      },
    );
  }

  void onPressPlayPause() {
    if (GetUtil.audioPlayer.playing) {
      GetUtil.audioPlayer.pause();
    } else {
      GetUtil.audioPlayer.play();
    }
    setState(() => playing = !playing);
  }

  void Function() onPressPlayPrev = () => GetUtil.audioPlayer.seekToPrevious();
  void Function() onPressPlayNext = () => GetUtil.audioPlayer.seekToNext();
}
