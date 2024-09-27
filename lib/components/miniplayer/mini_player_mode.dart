import 'package:dreamer_playlist/components/miniplayer/expandable_player.dart';
import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:flutter/material.dart';

class MiniPlayerMode extends StatelessWidget {
  final double height;
  const MiniPlayerMode(this.height);

  @override
  Widget build(BuildContext context) {
    double playerMaxHeight = MediaQuery.sizeOf(context).height;
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
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 240, 230, 200),    
            ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: [
              Row(children: [
                Icon(Icons.music_note),
                ValueListenableBuilder(
                      valueListenable:
                          GetitUtil.pageManager.currentPlayingNotifier,
                      builder: (context, mediaItem, child) {
                        return Text(
                          mediaItem?.title ??
                          'Not playing',
                      overflow: TextOverflow.ellipsis,
                        );
                      },
                    )
              ]),
              PlayerButtonbar(isMiniPlayer: true),
              PlaylistModeControl()
            ],
          ),
        )),
        SizedBox(
          height: progressIndicatorHeight,
          child: Opacity(
            opacity: elementOpacity,
              child: ValueListenableBuilder(
                valueListenable: GetitUtil.pageManager.progressBarValueNotifier,
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
