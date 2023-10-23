import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

final getIt = GetIt.instance;

class GetitUtil {
  static initRegistration() {
    getIt.registerSingleton(AudioPlayer());
    getIt.registerSingleton(ValueNotifier<Song?>(null));
    getIt.registerSingleton(ConcatenatingAudioSource(children: const []));
    getIt.registerSingleton(AppStates());

    List<Song> list = [];
    getIt.registerSingleton(list);
  }

  static AudioPlayer audioPlayer = getIt.get<AudioPlayer>();
  static ValueNotifier<Song?> currentlyPlaying =
      getIt.get<ValueNotifier<Song?>>();

  static ConcatenatingAudioSource audioSource =
      getIt.get<ConcatenatingAudioSource>();
  static AppStates appStates = getIt.get<AppStates>();
  static List<Song> songList = getIt.get<List<Song>>();

  static setSongs(List<Song> songs) {
    final playlistAudioSource = ConcatenatingAudioSource(
      useLazyPreparation:
          true, // Start loading next item just before reaching it
      // shuffleOrder: DefaultShuffleOrder(),
      children: [
        ...songs.map((song) => AudioSource.file(song.path!, tag: song.name)),
      ],
    );

    songList = songs;
    audioPlayer.setAudioSource(playlistAudioSource,
        initialIndex: 0, initialPosition: Duration.zero);
  }
}
