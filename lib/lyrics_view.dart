import 'package:dreamer_app/helper.dart';
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
  List<String> lyricsList = [""];
  List<String> timestampList = [""];

  int sectionNumber = 1;

  @override
  Widget build(BuildContext context) {
    Project currentProject =
        Provider.of<StateProvider>(context).currentProject!;
    print('aa');
    print(currentProject.lyricsList);
    print(currentProject.timestampList);

    if (currentProject.lyricsList == null) {
      lyricsList = List<String>.filled(sectionNumber, "");
    } else if (currentProject.lyricsList!.isEmpty) {
      lyricsList = List<String>.filled(sectionNumber, "");
    } else {
      lyricsList = currentProject.lyricsList!;
    }

    if (currentProject.timestampList == null) {
      timestampList = List<String>.filled(sectionNumber, "");
    } else if (currentProject.timestampList!.isEmpty) {
      timestampList = List<String>.filled(sectionNumber, "");
    } else {
      timestampList = currentProject.timestampList!;
    }

    sectionNumber = lyricsList.length;


    isEditing = widget.isEditing;
    if (!isEditing) {
      return Text(lyricsList.join("\n\n"));
    } else {
      return SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height / 2,
          child: Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(80),
                1: FlexColumnWidth(),
                2: FixedColumnWidth(36),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                ...buildLyricsTableRows(currentProject.name),
                buildAddSectionRow(
                  currentProject.name,
                )
              ]));
    }
  }

  List<TableRow> buildLyricsTableRows(projectName) {
    List<TableRow> tableRows = [];

    for (int index = 0; index < sectionNumber; index++) {
      tableRows.add(TableRow(
        children: <Widget>[
          // Timestamp(timestampList[index]),
          Text('timestamp'),
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: TextField(
                  controller:
                      TextEditingController(text: lyricsList[index]),
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  keyboardType: TextInputType.multiline,
                maxLines: null,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: "Add lyrics", // labelText
                    border: OutlineInputBorder(),
                  ),
                onChanged: (value) {
                  lyricsList[index] = value;

                  Project? currentProject =
                      Provider.of<StateProvider>(context, listen: false)
                          .currentProject;
                  LocalStorage()
                      .writeLyricsToFile(
                          currentProject!.name, lyricsList.join(delimiter))
                      .then((file) => print('finished writing lyrics to file'));
                },
              )),
          index == 0
              ? Container()
              : InkWell(
                  onTap: () {
                    showAlertDialogPopup(
                        context,
                        "Warning",
                        Text(
                            "Are you sure you want to delete this lyrics setcion?"),
                        [
                          displayTextButton(context, "Yes", callback: () async {
                            setState(() {
                              timestampList.removeAt(index);
                              lyricsList.removeAt(index);
                              sectionNumber -= 1;
                            });

                            await LocalStorage().writeSectionNumberToFile(
                                projectName, sectionNumber);
                          }),
                          displayTextButton(context, "No")
                        ]);
                  },
                  child: Icon(Icons.delete))
        ],
      ));
    }

    return tableRows;
  }

  TableRow buildAddSectionRow(projectName) {
    return TableRow(children: <Widget>[
      Container(),
      SizedBox(
        height: 50,
        child: InkWell(
            onTap: () {
              setState(() {
                timestampList.add("");
                lyricsList.add("");
                sectionNumber += 1;
              });
              LocalStorage()
                  .writeSectionNumberToFile(projectName, sectionNumber)
                  .then((file) => print(file.path));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add),
                Text("Add a section"),
              ],
            )),
      ),
      Container()
    ]);
  }
}
