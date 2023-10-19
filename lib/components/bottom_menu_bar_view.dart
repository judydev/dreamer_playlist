import 'package:flutter/material.dart';

class BottomMenuBarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white38,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            IconButton(
              style: ButtonStyle(
                  iconColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black54)),
              icon: const Icon(Icons.library_music_outlined),
              onPressed: () {},
            ),
            IconButton(
              style: ButtonStyle(
                  iconColor:
                      MaterialStateColor.resolveWith((states) => Colors.red)),
              icon: const Icon(Icons.queue_music),
              onPressed: () {},
            ),
            IconButton(
              style: ButtonStyle(
                  iconColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black54)),
              icon: const Icon(Icons.favorite),
              onPressed: () {},
            ),
            IconButton(
              style: ButtonStyle(
                  iconColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black54)),
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
