import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreamer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dreamer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  // Duration duration = Duration.zero;
  // Duration position = Duration.zero;

  void _selectFile() {
    FilePicker.platform.pickFiles().then((selectedFile) => {
          print(selectedFile),
          if (selectedFile != null)
            {
              for (final file in selectedFile.files)
                {
                  if (file.path == null) {throw Exception("invalid file path")},
                  audioPlayer.play(DeviceFileSource(file.path!)),
                  isPlaying = true
                }
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () => {_selectFile()},
              heroTag: null,
              tooltip: 'Import',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () => {
                if (isPlaying)
                  {audioPlayer.pause(), isPlaying = false}
                else
                  {audioPlayer.resume(), isPlaying = true}
              },
              heroTag: null,
              tooltip: 'Start/Stop',
              child: const Icon(Icons.play_arrow),
            )
          ],
        ),
      ),
    );
  }
}
