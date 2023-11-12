import 'package:flutter/material.dart';

class NewPlaylistPopup extends StatelessWidget {
  final Function callback;
  NewPlaylistPopup({required this.callback});

  @override
  Widget build(BuildContext context) {
    return (SizedBox(
      height: MediaQuery.sizeOf(context).height / 5,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Title",
            ),
            controller: TextEditingController(text: ''),
            onChanged: (value) => callback(value),
          ),
        ],
      ),
    ));
  }
}
