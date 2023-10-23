import 'package:dreamer_playlist/components/miniplayer/expandable_player.dart';
import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:flutter/material.dart';

class MiniPlayerMode extends StatefulWidget {
  final double height;
  final Function callback;
  const MiniPlayerMode(this.height, this.callback);

  @override
  State<MiniPlayerMode> createState() => _MiniPlayerModeState();
}

class _MiniPlayerModeState extends State<MiniPlayerMode> {
  late double height = widget.height;
  late Function callback = widget.callback;

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
                    child: Text(
                      GetitUtil.currentlyPlaying.value!.name ?? 'Not playing',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
              PlayerButtonbar(true, callback),
            ],
          ),
        )),
        SizedBox(
          height: progressIndicatorHeight,
          child: Opacity(
            opacity: elementOpacity,
            child: LinearProgressIndicator(value: 0.2), // Slider
          ),
        ),
      ],
    );
  }
}
