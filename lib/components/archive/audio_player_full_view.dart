// import 'dart:io';

// // import 'package:audio_service/audio_service.dart';
// import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
// import 'package:dreamer_playlist/models/song.dart';
// import 'package:dreamer_playlist/database/song_data_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:provider/provider.dart';

// class AudioPlayerFullView extends StatefulWidget {
//   // final Song? song;
//   final String? currentPlayingSongId;
//   // final String? filePath;

//   AudioPlayerFullView(this.currentPlayingSongId);

//   @override
//   State<AudioPlayerFullView> createState() => _AudioPlayerFullViewState();
// }

// class _AudioPlayerFullViewState extends State<AudioPlayerFullView> {
//   late String? currentPlayingSongId = widget.currentPlayingSongId;
//   File? file;

//   // bool isAudioFilePlaying = false;

//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;

//   // late StorageProvider storageProvider = Provider.of<StorageProvider>(context);
//   // late Future<File?> _getAudioFile;
//   late SongDataProvider songDataProvider =
//       Provider.of<SongDataProvider>(context);
//   late Future<Song?> _getSong;

//   // late AudioHandler _audioHandler;
//   late AudioPlayer _player;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     // storageProvider = Provider.of<StorageProvider>(context);
//     if (currentPlayingSongId != null) {
//       _getSong = songDataProvider.getSongById(currentPlayingSongId!);
//     }
//     // _getAudioFile = storageProvider.getAudioFile(filePath);
//   }

//   @override
//   void initState() {
//     super.initState();

//     // _audioHandler = GetIt.instance.get<AudioHandler>();
//     _player = GetIt.instance.get<AudioPlayer>();

//     // file = StorageProvider().getAudioFile(filePath!);
//     setState(() {
//       // audioFilePlayer.onPlayerStateChanged.listen((state) {
//       //   setState(() {
//       //     isAudioFilePlaying = state == PlayerState.playing;
//       //   });
//       // });

//       // audioFilePlayer.onPositionChanged.listen((newPosition) {
//       //   setState(() {
//       //     position = newPosition;
//       //   });
//       // });

//       // audioFilePlayer.onDurationChanged.listen((newDuration) {
//       //   setState(() {
//       //     duration = newDuration;
//       //   });
//       // });

//       // audioFilePlayer.setReleaseMode(ReleaseMode.loop);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (currentPlayingSongId == null) {
//       return Container();
//     }
//     return FutureBuilderWrapper(_getSong, (context, snapshot) {
//       Song? song = snapshot.data;
//       if (song != null) {
//         file = File(song.path!);
//       }
//       return SizedBox(
//           height: MediaQuery.of(context).size.height / 2,
//           child: Column(
//             children: [
//               Spacer(),
//               SizedBox(
//                   child: Icon(
//                 Icons.music_video_outlined,
//                 size: 36,
//               )),
//               Slider(
//                 min: 0.0,
//                 thumbColor: Colors.amber,
//                 activeColor: Colors.amberAccent,
//                 max: duration.inMilliseconds.toDouble(),
//                 value: position.inMilliseconds.toDouble(),
//                 onChanged: ((double value) {
//                   Duration newPosition = Duration(milliseconds: value.toInt());
//                   // audioFilePlayer.seek(newPosition);
//                   // audioFilePlayer.resume();

//                   setState(() {
//                     position = newPosition;
//                   });
//                 }),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.skip_previous),
//                     onPressed: () {
//                       print('play previous');
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.play_circle),
//                     onPressed: () async {
//                       print('play');
//                       print(_player.audioSource);
//                       await _player.play();
//                       if (song != null) {
//                         // await _audioHandler.playMediaItem(
//                         //     MediaItem(id: song.id, title: song.name!));
//                       }
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.pause_circle),
//                     onPressed: () {
//                       print('pause');
//                       _player.pause();
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.skip_next),
//                     onPressed: () {
//                       print('play next');
//                       _player.seekToNext();
//                     },
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                       onPressed: () {
//                         print('shuffle');
//                       },
//                       icon: Icon(Icons.shuffle)),
//                   IconButton(
//                       onPressed: () {
//                         print('loop');
//                       },
//                       icon: Icon(Icons.loop)),
//                   IconButton(
//                       onPressed: () {
//                         print('add to fav');
//                       },
//                       icon: Icon(Icons.favorite_border)),
//                   // IconButton(
//                   //     onPressed: () {
//                   //       print('playback speed');
//                   //     },
//                   //     icon: Icon(Icons))
//                 ],
//               ),
//             ],
//           ));
//       // }));
//     });
//   }
// }
