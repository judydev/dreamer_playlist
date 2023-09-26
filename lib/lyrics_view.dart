import 'package:flutter/material.dart';

class LyricsView extends StatefulWidget {
  final String lyrics;

  LyricsView(this.lyrics);

  @override
  LyricsViewState createState() => LyricsViewState();
}

class LyricsViewState extends State<LyricsView> {
  String lyrics = "";

  @override
  void initState() {
    super.initState();

    lyrics = widget.lyrics;
  }

  @override
  Widget build(BuildContext context) {
    return lyrics.isNotEmpty
        ? ListView(
            children: [
              for (String line in lyrics.split("\n")) Text(line),
            ],
          )
        : Text("No lyrics");
  }
}

class ListBuilder extends StatefulWidget {
  const ListBuilder({
    super.key,
    required this.selectedList,
    required this.isSelectionMode,
    required this.onSelectionChange,
  });

  final bool isSelectionMode;
  final List<bool> selectedList;
  final Function(bool)? onSelectionChange;

  @override
  State<ListBuilder> createState() => _ListBuilderState();
}

class _ListBuilderState extends State<ListBuilder> {
  void _toggle(int index) {
    if (widget.isSelectionMode) {
      setState(() {
        widget.selectedList[index] = !widget.selectedList[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.selectedList.length,
        itemBuilder: (_, int index) {
          return ListTile(
              onTap: () => _toggle(index),
              onLongPress: () {
                if (!widget.isSelectionMode) {
                  setState(() {
                    widget.selectedList[index] = true;
                  });
                  widget.onSelectionChange!(true);
                }
              },
              trailing: widget.isSelectionMode
                  ? Checkbox(
                      value: widget.selectedList[index],
                      onChanged: (bool? x) => _toggle(index),
                    )
                  : const SizedBox.shrink(),
              title: Text('item $index'));
        });
  }
}
