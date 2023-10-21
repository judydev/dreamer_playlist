import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/providers/app_state_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomMenuBarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white38,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              style: ButtonStyle(
                  iconColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black54)),
              icon: const Icon(Icons.library_music_outlined),
              onPressed: () {
                Provider.of<AppStateDataProvider>(context, listen: false)
                    .updateCurrentTab(CurrentTab.library);
              },
            ),
            IconButton(
              style: ButtonStyle(
                  iconColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black54)),
              icon: const Icon(Icons.queue_music),
              onPressed: () {
                Provider.of<AppStateDataProvider>(context, listen: false)
                    .updateCurrentTab(CurrentTab.playlists);
              },
            ),
            IconButton(
              style: ButtonStyle(
                  iconColor: MaterialStateColor.resolveWith(
                      (states) => Colors.red)),
              icon: const Icon(Icons.favorite),
              onPressed: () {
                Provider.of<AppStateDataProvider>(context, listen: false)
                    .updateCurrentTab(CurrentTab.favorites);
              },
            ),
            IconButton(
              style: ButtonStyle(
                  iconColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black54)),
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Provider.of<AppStateDataProvider>(context, listen: false)
                    .updateCurrentTab(CurrentTab.preferences);
              },
            ),
            IconButton(
              style: ButtonStyle(
                  iconColor:
                      MaterialStateColor.resolveWith((states) => Colors.blue)),
              icon: const Icon(Icons.pause_circle),
              onPressed: () {
                Provider.of<AppStateDataProvider>(context, listen: false)
                    .updateAppState(AppStateKey.currentPlaying, null);
              },
            ),
          ],
        ),
      ),
    );
  }
}
