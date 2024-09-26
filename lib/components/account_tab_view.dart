import 'package:dreamer_playlist/components/library_tab_view.dart';
import 'package:dreamer_playlist/components/playlist_tab_view.dart';
import 'package:dreamer_playlist/components/songlist_view.dart';
import 'package:dreamer_playlist/components/playlists_tab_view.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:flutter/material.dart';

class AccountTabView extends StatefulWidget {
  @override
  State<AccountTabView> createState() => _AccountTabViewState();
}

class _AccountTabViewState extends State<AccountTabView> {
  bool showPlaylists = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
       
        ],
      ),
    );
  }
}
