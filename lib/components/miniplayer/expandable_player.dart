// Modified from: https://github.com/dxvid-pts/miniplayer/blob/master/example/lib/widgets/player.dart

import 'package:dreamer_playlist/components/miniplayer/mini_player_mode.dart';
import 'package:dreamer_playlist/components/miniplayer/miniplayer.dart';
import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
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
  bool isShuffle = GetitUtil.audioPlayer.shuffleModeEnabled;
  AudioPlayer audioPlayer = GetitUtil.audioPlayer;

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
        currentlyPlayingNotifier.value = null,
        audioPlayer.stop()
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
                        currentlyPlayingNotifier.value != null
                            ? SongTile(
                                currentlyPlayingNotifier.value!,
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
                                // IconButton(
                                //     onPressed: () => play(isShuffle: true),
                                //     icon: Icon(Icons.shuffle)),
                                getShuffleButton(),
                                ValueListenableBuilder(
                                    valueListenable: loopModeNotifier,
                                    builder: ((context, LoopMode loopModeValue,
                                        child) {
                                      switch (loopModeValue) {
                                        case LoopMode.all:
                                          return IconButton(
                                              onPressed: () {
                                                audioPlayer
                                                    .setLoopMode(LoopMode.one);
                                                loopModeNotifier.value =
                                                    LoopMode.one;
                                              },
                                              icon: Icon(Icons.repeat_on));
                                        case LoopMode.one:
                                          return IconButton(
                                              onPressed: () {
                                                audioPlayer
                                                    .setLoopMode(LoopMode.off);
                                                loopModeNotifier.value =
                                                    LoopMode.off;
                                              },
                                              icon: Icon(Icons.repeat_one_on));
                                        case LoopMode.off:
                                        default:
                                          return IconButton(
                                              onPressed: () {
                                                audioPlayer
                                                    .setLoopMode(LoopMode.all);
                                                loopModeNotifier.value =
                                                    LoopMode.all;
                                              },
                                              icon: Icon(Icons.repeat));
                                      }
                                    }))
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
                                  PlayerButtonbar(
                                    isMiniPlayer: false,
                                    callback: () {
                                    setState(() {
                                      isPlaying = !isPlaying;
                                    });
                                    },
                                  ),
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

ValueListenableBuilder<ShuffleMode> getShuffleButton() {
    return ValueListenableBuilder(
        valueListenable: shuffleModeNotifier,
        builder: (context, shuffleMode, child) {
          bool isShuffle = shuffleMode == ShuffleMode.on;
          return IconButton(
              onPressed: () {
                audioPlayer.setShuffleModeEnabled(!isShuffle);
                updateEffectiveIndicesNotifier();
                updateShuffleModeNotifier();

                print(audioPlayer.effectiveIndices);
                setState(() {
                  isShuffle = !isShuffle;
                });
              },
              icon: isShuffle ? Icon(Icons.shuffle_on) : Icon(Icons.shuffle));
        });
  }
}

class PlayerButtonbar extends StatelessWidget {
  final bool isMiniPlayer;
  final Function callback;
  PlayerButtonbar({required this.isMiniPlayer, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getButtonPlayPrev(),
        getButtonPlayPause(isMiniPlayer, callback),
        getButtonPlayNext(),
      ],
    );
  }

final AudioPlayer audioPlayer = GetitUtil.audioPlayer;

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

  IconButton getButtonPlayPrev() => IconButton(
      onPressed: () {
        audioPlayer.seekToPrevious();
        audioPlayer.play();
      },
      icon: Icon(Icons.skip_previous));

  IconButton getButtonPlayNext() => IconButton(
      onPressed: () {
        audioPlayer.seekToNext();
        audioPlayer.play();
      },
      icon: Icon(Icons.skip_next));
}
