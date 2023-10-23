// Modified from: https://github.com/dxvid-pts/miniplayer/blob/master/example/lib/widgets/player.dart

import 'package:dreamer_playlist/components/miniplayer/mini_player_mode.dart';
import 'package:dreamer_playlist/components/miniplayer/miniplayer.dart';
import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/components/song_tile_reorder.dart';
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
        GetitUtil.currentlyPlaying.value = null,
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

          print(GetitUtil.audioPlayer.audioSource?.sequence);

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
                        GetitUtil.currentlyPlaying.value != null
                            ? SongTile(
                                GetitUtil.currentlyPlaying.value!,
                                onTapOverride: () {},
                              )
                            : ListTileWrapper(
                                leading: Icon(Icons.music_video),
                                title: 'Not playing',
                              ),
                        // Music Queue
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Playing Next'),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      print('TODO: playing next shuffle');
                                    },
                                    icon: Icon(Icons.shuffle)),
                                IconButton(
                                    onPressed: () {
                                      print('TODO: playing next loop');
                                    },
                                    icon: Icon(Icons.loop))
                              ],
                            )
                          ],
                        ),
                        Expanded(
                          child: ListView(children: [
                            ...GetitUtil.audioPlayer.audioSource!.sequence.map(
                                (IndexedAudioSource as) =>
                                    SongTileReorder(as.tag)),
                          ]),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: LinearProgressIndicator(value: 0.4), // Slider
                        ), // slide bar
                        PlayerButtonbar(false, () {
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: LinearProgressIndicator(value: 0.1), // volume
                        ),
                        SizedBox(height: 30)
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


