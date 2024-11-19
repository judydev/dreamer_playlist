// Modified from: https://github.com/dxvid-pts/miniplayer/blob/master/example/lib/widgets/player.dart

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:dreamer_playlist/components/miniplayer/mini_player_mode.dart';
import 'package:dreamer_playlist/components/miniplayer/miniplayer.dart';
import 'package:dreamer_playlist/components/miniplayer/music_queue.dart';
import 'package:dreamer_playlist/components/miniplayer/utils.dart';
import 'package:dreamer_playlist/helpers/audio_handler.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
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
  MyAudioHandler _audioHandler = GetitUtil.audioHandler;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double playerMaxHeight = screenHeight + kBottomNavigationBarHeight * 2 + 40;

    return Miniplayer(
      valueNotifier: playerExpandProgress,
      minHeight: playerMinHeight,
      maxHeight: playerMaxHeight,
      controller: controller,
      elevation: 4,
      curve: Curves.easeOut,
      builder: (height, percentage) {
        final bool isMiniPlayer = percentage < miniplayerPercentageDeclaration;
        if (isMiniPlayer) {
          // Mini Player
          return MiniPlayerMode(height);
        } else {
          // Full Screen Player
          var percentageExpandedPlayer = percentageFromValueInRange(
              min: playerMaxHeight * miniplayerPercentageDeclaration +
                  playerMinHeight,
              max: playerMaxHeight,
              value: height);
          if (percentageExpandedPlayer < 0) percentageExpandedPlayer = 0;

          return Column(
            children: [
              const Icon(Icons.horizontal_rule),
              // Currently playing
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: const Text('Currently Playing'),
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: GetitUtil.pageManager.currentPlayingNotifier,
                  builder: ((context, mediaItem, child) {
                    return ListTileWrapper(
                        leading: const Icon(Icons.music_video),
                        title: mediaItem == null
                            ? 'Not playing'
                            : mediaItem.title);
                  })),
              height > 200
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Queue'),
                            Row(children: [
                              getQueueShuffleButton(),
                              getQueueLoopButton()
                            ])
                          ]))
                  : SizedBox.shrink(),
              height > 200 ? Expanded(child: MusicQueue()) : SizedBox.shrink(),
              height > screenHeight - 200 // prevent bottom overflow
                  ? Column(
                      children: [
                        // Progress Bar Slider
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ValueListenableBuilder(
                              valueListenable: GetitUtil.pageManager.progressBarValueNotifier,
                              builder: ((context, progressValue, child) {
                                Duration? duration = _audioHandler.mediaItem.value?.duration;

                                return Column(children: [
                                  Slider(
                                    activeColor: Theme.of(context).colorScheme.primary,
                                    inactiveColor: Theme.of(context).colorScheme.primaryContainer,
                                    min: 0,
                                    max: 1,
                                    value: progressValue > 1 ? 1 : progressValue,
                                    onChanged: (newProgressValue) {
                                      if (duration == null) return;

                                      Duration newPosition = duration * newProgressValue;
                                      _audioHandler.seek(newPosition);
                                    },
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Current song position
                                            Text(
                                                convertDurationToTimeDisplay(
                                                    duration != null
                                                        ? duration * progressValue
                                                        : Duration.zero),
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            // Sleep Timer
                                            ValueListenableBuilder<int>(
                                              valueListenable: sleepTimerNotifier,
                                              builder: (context, sleepTimerCountdown, child) {
                                                return sleepTimerCountdown > 0 ? Text(
                                                  'Sleep Timer: ${convertDurationToTimeDisplay(
                                                    Duration(seconds: sleepTimerCountdown))}',
                                                  style: const TextStyle(
                                                    fontSize: 12)) : const SizedBox.shrink();
                                              }
                                            ),
                                            // Song length
                                            Text(
                                                convertDurationToTimeDisplay(
                                                    duration ?? Duration.zero),
                                                style: const TextStyle(
                                                    fontSize: 12))
                                          ])),
                                ]);
                              }),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: PlayerButtonbar(isMiniPlayer: false),
                        ),
                      ],
                    )
                  : const SizedBox.shrink()
            ],
          );
        }
      },
    );
  }

  ValueListenableBuilder<bool> getQueueShuffleButton() {
    return ValueListenableBuilder(
        valueListenable: shuffleModeNotifier,
        builder: (context, isShuffleModeEnabled, child) {
          return IconButton(
              onPressed: () async {
                if (isEmptyQueue()) return;

                if (isShuffleModeEnabled) {
                  await _audioHandler
                      .setShuffleMode(AudioServiceShuffleMode.none);
                } else {
                  await _audioHandler
                      .setShuffleMode(AudioServiceShuffleMode.all);
                  await _audioHandler.shuffle();
                }

                updateQueueIndicesNotifier();
              },
              icon: isShuffleModeEnabled
                  ? const Icon(Icons.shuffle_on_outlined)
                  : const Icon(Icons.shuffle_outlined));
        });
  }

  ValueListenableBuilder<LoopMode> getQueueLoopButton() {
    return ValueListenableBuilder(
        valueListenable: loopModeNotifier,
        builder: ((context, LoopMode loopModeValue, child) {
          Icon icon = const Icon(Icons.repeat_outlined);
          switch (loopModeValue) {
            case LoopMode.all:
              icon = const Icon(Icons.repeat_on_outlined);
              break;
            case LoopMode.one:
              icon = const Icon(Icons.repeat_one_on_outlined);
              break;
            default:
          }

          return IconButton(
              onPressed: () => _audioHandler.setRepeatMode(GetitUtil
                  .audioHandler
                  .loopModeToRepeatMode(_getNextLoopMode(loopModeValue))),
              icon: icon);
        }));
  }

  _getNextLoopMode(LoopMode currentMode) {
    // LoopMode: [off, all, one]
    int currentIndex = LoopMode.values.indexOf(currentMode);
    if (currentIndex == 0) {
      return LoopMode.values[LoopMode.values.length - 1];
    } else {
      return LoopMode.values[currentIndex - 1];
    }
  }
}

class PlayerButtonbar extends StatelessWidget {
  final bool isMiniPlayer;
  PlayerButtonbar({required this.isMiniPlayer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Speed control
        isMiniPlayer ? SizedBox.shrink() : SpeedButton(),
        // Playback controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getButtonPlayPrev(),
            getButtonPlayPause(),
            getButtonPlayNext(),
          ],
        ),
        // Sleep timer
        isMiniPlayer ? SizedBox.shrink() : TimerButton(),
      ],
    );
  }

  final _audioHandler = GetitUtil.audioHandler;

  ValueListenableBuilder<PlayingState> getButtonPlayPause() =>
      ValueListenableBuilder(
          valueListenable: playingStateNotifier,
          builder: ((context, playingStateValue, child) {
            bool isPlaying = playingStateValue == PlayingState.playing;

            return IconButton(
              icon: isPlaying
                  ? isMiniPlayer
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.pause_circle_filled)
                  : isMiniPlayer
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.play_circle),
              iconSize: isMiniPlayer ? 25 : 50,
              onPressed: () async {
                if (isEmptyQueue()) return;

                if (isPlaying) {
                  await _audioHandler.pause();
                } else {
                  await _audioHandler.play();
                }
              },
            );
          }));

  IconButton getButtonPlayPrev() => IconButton(
      onPressed: () {
        if (isEmptyQueue()) return;
        GetitUtil.pageManager.onPreviousSongButtonPressed();
      },
      iconSize: isMiniPlayer ? 25 : 35,
      icon: const Icon(Icons.skip_previous));

  IconButton getButtonPlayNext() => IconButton(
      onPressed: () {
        if (isEmptyQueue()) return;
        GetitUtil.pageManager.onNextSongButtonPressed();
      },
      iconSize: isMiniPlayer ? 25 : 35,
      icon: const Icon(Icons.skip_next));
}

String convertDurationToTimeDisplay(Duration duration) {
  String mm = convertToTwoDigits(duration.inMinutes % 60);
  String ss = convertToTwoDigits(duration.inSeconds % 60);
  if (duration.inHours > 0) {
    String hh = convertToTwoDigits(duration.inHours);
    return '$hh:$mm:$ss';
  }
  return '$mm:$ss';
}

String convertToTwoDigits(int num) {
  String s = num.toString();
  if (s.length == 1) {
    return '0$s';
  }
  return s;
}

/// Speed control button
class SpeedButton extends StatefulWidget {
  const SpeedButton({super.key});

  @override
  State<SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<SpeedButton> {
  final _audioHandler = GetitUtil.audioHandler;
  late double _speed;

  @override
  void initState() {
    super.initState();
    _speed = _audioHandler.audioPlayer.speed;
  }

  void _updateSpeed(double speed) async {
    await _audioHandler.audioPlayer.setSpeed(speed);
    setState(() {
      _speed = speed;
    });
  }

  PopupMenuItem<double> _buildSpeedMenuItem(double speed) {
    return PopupMenuItem(
      height:20,
      value: speed,
      child: Text('${speed.toString()}x'),
      onTap: () => _updateSpeed(speed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.only(left: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: _speed != 1.0 ? Theme.of(context).colorScheme.secondaryContainer : null,
        ),
        child: PopupMenuButton<double>(
          offset: const Offset(-10, -260),
          position: PopupMenuPosition.over,
          child: Text("${_speed.toString()}x",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          itemBuilder: (context) => [
            _buildSpeedMenuItem(2.0),
            const PopupMenuDivider(),
            _buildSpeedMenuItem(1.75),
            const PopupMenuDivider(),
            _buildSpeedMenuItem(1.5),
            const PopupMenuDivider(),
            _buildSpeedMenuItem(1.25),
            const PopupMenuDivider(),
            _buildSpeedMenuItem(1.0),
            const PopupMenuDivider(),
            _buildSpeedMenuItem(0.75),
            const PopupMenuDivider(),
            _buildSpeedMenuItem(0.5),
          ],
        ),
      ),
    );
  }
}

/// Sleep timer button
class TimerButton extends StatefulWidget {
  const TimerButton({super.key});

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: ValueListenableBuilder<int>(
        valueListenable: sleepTimerNotifier,
        builder: (context, sleepTimerValue, child) {
          return Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.only(right: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: sleepTimerValue > 0
                ? Theme.of(context).colorScheme.secondaryContainer 
                : null,
            ),
            child: _SleepTimerButton(),
          );
        },
      ),
    );
  }
}

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(10, -260),
      position: PopupMenuPosition.over,
      child: Icon(
        Icons.timer_outlined,
        color: Theme.of(context).colorScheme.secondary,
      ),
      itemBuilder: (context) => [
        _buildTimerMenuItem('1 Hour'),
        const PopupMenuDivider(),
        _buildTimerMenuItem('45 Minutes'),
        const PopupMenuDivider(),
        _buildTimerMenuItem('30 Minutes'),
        const PopupMenuDivider(),
        _buildTimerMenuItem('15 Minutes'),
        const PopupMenuDivider(),
        _buildTimerMenuItem('10 Minutes'),
        const PopupMenuDivider(),
        _buildTimerMenuItem('5 Minutes'),
        const PopupMenuDivider(),
        _buildTimerMenuItem('Off'),
      ],
    );
  }

  PopupMenuItem<String> _buildTimerMenuItem(String label) {
    return PopupMenuItem(
      height: 20,
      value: label,
      child: Text(
        label,
        softWrap: true,
      ),
      onTap: () {
        if (label != 'Off') {
          // Set a sleep timer
          Duration duration;
          switch (label) {
            case '1 Hour':
              duration = const Duration(hours: 1);
              break;
            case '45 Minutes':
              duration = const Duration(minutes: 45);
              break;
            case '30 Minutes':
              duration = const Duration(minutes: 30);
              break;
            case '15 Minutes':
              duration = const Duration(minutes: 15);
              break;
            case '10 Minutes':
              duration = const Duration(minutes: 10);
              break;
            case '5 Minutes':
              duration = const Duration(minutes: 5);
              break;
            default:
              return;
          }

          GetitUtil.appStates.sleepTimer?.cancel();
          sleepTimerNotifier.value = duration.inSeconds;
          GetitUtil.appStates.sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (sleepTimerNotifier.value <= 0) {
              GetitUtil.audioHandler.audioPlayer.pause();
              GetitUtil.appStates.sleepTimer = null;
              timer.cancel();
              return;
            }
            sleepTimerNotifier.value--;
          });
        } else {
          sleepTimerNotifier.value = 0;
          GetitUtil.appStates.sleepTimer?.cancel();
          GetitUtil.appStates.sleepTimer = null;
        }
      },
    );
  }
}
