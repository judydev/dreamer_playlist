import 'package:dreamer_playlist/components/miniplayer/expandable_player.dart';
import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:flutter/material.dart';

class MiniPlayerMode extends StatelessWidget {
  final double height;
  const MiniPlayerMode(this.height);

  @override
  Widget build(BuildContext context) {
    double playerMaxHeight = MediaQuery.of(context).size.height;
    final percentageMiniplayer = percentageFromValueInRange(
        min: playerMinHeight,
        max:
            playerMaxHeight * miniplayerPercentageDeclaration + playerMinHeight,
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
                    child: ValueListenableBuilder(
                      valueListenable: currentlyPlayingNotifier,
                      builder: (context, currentlyPlayingValue, child) {
                        return Text(
                          currentlyPlayingValue?.name ??
                          'Not playing',
                      overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  )),
              PlayerButtonbar(isMiniPlayer: true),
            ],
          ),
        )),
        SizedBox(
          height: progressIndicatorHeight,
          child: Opacity(
            opacity: elementOpacity,
              child: ValueListenableBuilder(
                valueListenable: progressBarValueNotifier,
                builder: ((context, progressBarValue, child) {
                  return LinearProgressIndicator(value: progressBarValue);
                }),
              )
          ),
        ),
      ],
    );
  }
}
