// Modified from: https://github.com/dxvid-pts/miniplayer/blob/master/example/lib/widgets/player.dart

import 'package:dreamer_playlist/components/library_view.dart';
import 'package:dreamer_playlist/components/miniplayer/mini_player_mode.dart';
import 'package:dreamer_playlist/components/miniplayer/miniplayer.dart';
import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const double playerMinHeight = 70;
const miniplayerPercentageDeclaration = 0.2;

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController controller = MiniplayerController();

class ExpandablePlayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpandablePlayerState();
}

class _ExpandablePlayerState extends State<ExpandablePlayer> {
  bool isPlaying = GetitUtil.audioPlayer.playing;
  LoopMode loopMode = LoopMode.off;

  @override
  Widget build(BuildContext context) {
    double playerMaxHeight = MediaQuery.of(context).size.height;
    return Miniplayer(
      valueNotifier: playerExpandProgress,
      minHeight: playerMinHeight,
      maxHeight: playerMaxHeight,
      controller: controller,
      elevation: 4,
      onDismissed: () => {
        // dismiss mini player
        GetitUtil.currentlyPlayingNotifier.value = null,
        GetitUtil.audioPlayer.stop()
      },
      curve: Curves.easeOut,
      builder: (height, percentage) {
        final bool isMiniPlayer = percentage < miniplayerPercentageDeclaration;

        if (!isMiniPlayer) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Opacity(
                    opacity: percentageExpandedPlayer,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.horizontal_rule),
                        // Currently playing
                        GetitUtil.currentlyPlayingNotifier.value != null
                            ? SongTile(
                                GetitUtil.currentlyPlayingNotifier.value!,
                                onTapOverride: () {},
                              )
                            : ListTileWrapper(
                                leading: Icon(Icons.music_video),
                                title: 'Not playing',
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Playing Next'),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () => play(isShuffle: true),
                                    icon: Icon(Icons.shuffle)),
                                getLoopButton()
                              ],
                            )
                          ],
                        ),
                        Expanded(
                          child: MusicQueue()),
                        height > 300 // prevent bottom overflow
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: LinearProgressIndicator(
                                        value: 0.4), // Slider
                                  ), // slide bar
                                  PlayerButtonbar(false, () {
                                    setState(() {
                                      isPlaying = !isPlaying;
                                    });
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: LinearProgressIndicator(
                                        value: 0.1), // volume
                                  ),
                                  SizedBox(height: 30)
                                ],
                              )
                            : SizedBox.shrink()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mini Player
          return MiniPlayerMode(
              height, () => setState(() => isPlaying = !isPlaying));
        }
      },
    );
  }

  IconButton getLoopButton() {
    switch (loopMode) {
      case LoopMode.all:
        return IconButton(
            onPressed: () {
              GetitUtil.audioPlayer.setLoopMode(LoopMode.one);
              setState(() {
                loopMode = LoopMode.one;
              });
            },
            icon: Icon(Icons.repeat_on));
      case LoopMode.one:
        return IconButton(
            onPressed: () {
              GetitUtil.audioPlayer.setLoopMode(LoopMode.off);
              setState(() {
                loopMode = LoopMode.off;
              });
            },
            icon: Icon(Icons.repeat_one_on));
      case LoopMode.off:
      default:
        return IconButton(
            onPressed: () {
              GetitUtil.audioPlayer.setLoopMode(LoopMode.all);
              setState(() {
                loopMode = LoopMode.all;
              });
            },
            icon: Icon(Icons.repeat));
    }
  }
}

class PlayerButtonbar extends StatelessWidget {
  final bool isMiniPlayer;
  final Function callback;
  const PlayerButtonbar(this.isMiniPlayer, this.callback);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buttonPlayPrevious,
        getButtonPlayPause(isMiniPlayer, callback),
        buttonPlayNext,
      ],
    );
  }
}

IconButton getButtonPlayPause(bool isMiniPlayer, Function callback) =>
    IconButton(
      icon: GetitUtil.audioPlayer.playing
          ? Icon(isMiniPlayer ? Icons.pause : Icons.pause_circle_filled)
          : Icon(isMiniPlayer ? Icons.play_arrow : Icons.play_circle),
      iconSize: isMiniPlayer ? 25 : 50,
      onPressed: () {
        if (GetitUtil.audioPlayer.playing) {
          GetitUtil.audioPlayer.pause();
        } else {
          GetitUtil.audioPlayer.play();
        }
        callback();
      },
    );

IconButton buttonPlayPrevious = IconButton(
    onPressed: () {
      GetitUtil.audioPlayer.seekToPrevious();
      GetitUtil.audioPlayer.play();
    },
    icon: Icon(Icons.skip_previous));

IconButton buttonPlayNext = IconButton(
    onPressed: () {
      GetitUtil.audioPlayer.seekToNext();
      GetitUtil.audioPlayer.play();
    },
    icon: Icon(Icons.skip_next));
