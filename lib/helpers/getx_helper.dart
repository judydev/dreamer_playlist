import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

final getIt = GetIt.instance;

class GetUtil {
  static AudioPlayer audioPlayer = getIt.get<AudioPlayer>();
  static ValueNotifier<Song?> currentlyPlaying =
      getIt.get<ValueNotifier<Song?>>();

  // static AudioPlayer getAudioPlayer() {
  //   return getIt.get<AudioPlayer>();
  // }

  // static ValueNotifier<Song?> getCurrentPlaying() {
  //   return getIt.get<ValueNotifier<Song?>>();
  // }
}

// import 'package:flutter/material.dart';
// Get.put(AudioPlayer());