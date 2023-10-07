import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/project.dart';
import 'package:dreamer_app/project_view.dart';
import 'package:dreamer_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LyricsView extends StatefulWidget {
  final bool isEditing;
  LyricsView(this.isEditing);

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  late bool isEditing;
  List<double> timestamps = [];
  List<String>? lyricsList = [""];
  List<String>? timestampsList = [""];

  @override
  Widget build(BuildContext context) {
    lyricsList =
        Provider.of<StateProvider>(context).currentProject?.lyricsList ?? [""];

    isEditing = widget.isEditing;
    if (!isEditing) {
      return Text(lyricsList == null ? "" : lyricsList!.join("\n\n"));
    } else {
      return SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height / 2,
          child: GridView.count(
            crossAxisCount: 2,
            children: List.generate(2, (int index) {
              if (index.isOdd) {
                int listIndex = index ~/ 2;
                return TextField(
                  controller:
                      TextEditingController(text: lyricsList?[listIndex]),
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: "Add lyrics", // labelText
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // auto-save lyrcis to local storage
                    // LocalStorage.getlocalFile();
                    print(index / 2);
                    if (lyricsList != null) {
                      print(lyricsList);
                      print(index ~/ 2);
                      lyricsList?[listIndex] = value;
                    }
                    Project? currentProject =
                        Provider.of<StateProvider>(context, listen: false)
                            .currentProject;
                    LocalStorage().writeLyricsToFile(
                        currentProject!.name, lyricsList!.join(delimiter));
                  },
                );
              } else {
                return (SizedBox(
                  height: 50,
                  width: 10,
                  child: Text("Timestamps"),
                ));
              }
            }),
          ));
    }
  }
}
