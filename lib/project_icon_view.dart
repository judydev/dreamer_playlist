import 'package:flutter/material.dart';

class ProjectIconView extends StatelessWidget {
  final String title;
  final Function? callback;

  ProjectIconView(this.title, {this.callback});
  
  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        FloatingActionButton(
            shape: CircleBorder(),
            onPressed: () => {
                  if (callback != null) {callback!()}
                },
            child: Icon(Icons.add)
        ),
        Text(title),
        // Text(lastModifiedDateTime)
      ],
    ));
  }
}
