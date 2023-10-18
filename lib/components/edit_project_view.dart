import 'package:dreamer_playlist/models/project.dart';
import 'package:flutter/material.dart';

class EditProjectView extends StatefulWidget {
  final Project project;
  final Function callback;
  EditProjectView(this.project, this.callback);

  @override
  State<StatefulWidget> createState() => _EditProjectViewState();
}

class _EditProjectViewState extends State<EditProjectView> {
  late Project project = widget.project;
  late String name = project.name;
  late String? description = project.description;

  @override
  Widget build(BuildContext context) {
    return (SizedBox(
      height: MediaQuery.of(context).size.height / 5,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: "Project Name",
            ),
            initialValue: project.name,
            onChanged: (value) {
              setState(() {
                name = value;
              });

              project.name = value;
              widget.callback(project);
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Description (optional)",
              border: OutlineInputBorder(),
            ),
            initialValue: project.description,
            onTapOutside: (event) {},
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            onChanged: (value) {
              setState(() {
                description = value;
              });

              project.description = value;
              widget.callback(project);
            },
          ),
        ],
      ),
    ));
  }
}
