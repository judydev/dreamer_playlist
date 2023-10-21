import 'package:flutter/material.dart';

class MusicSearchBar extends StatefulWidget {
  const MusicSearchBar({super.key});

  @override
  State<MusicSearchBar> createState() => _MusicSearchBarState();
}

class _MusicSearchBarState extends State<MusicSearchBar> {
  @override
  Widget build(BuildContext context) {
    return SearchBar();
  }
}
