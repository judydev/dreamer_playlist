// import 'package:dreamer_app/helper.dart';
// import 'package:dreamer_app/local_storage.dart';
import 'package:dreamer_app/project.dart';
// import 'package:dreamer_app/providers.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class EditProjectView extends StatefulWidget {
  final Project project;
  final Function callback;
  EditProjectView(this.project, this.callback);

  @override
  State<StatefulWidget> createState() => _EditProjectViewState();
}

class _EditProjectViewState extends State<EditProjectView> {
  late Project project = widget.project;
  late String name = project.name!;
  late String? description = project.description;

  @override
  Widget build(BuildContext context) {
    // projectName = project.name;
    // projectDescription = "";
    // final stateProvider = Provider.of<StateProvider>(context);
    print('editView build');
    print(project.name);
    print(project.description);

    return (SizedBox(
      height: 160,
      width: 500,
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
              // widget.callback({"name": value});

              project.name = value;
              widget.callback(project);
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              // labelText: "Description (optional)",
              hintText: "Description (optional)",
              // hintStyle: TextStyle(),
              border: OutlineInputBorder(),
            ),
            initialValue: project.description,
            onTapOutside: (event) {},
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            // expands: true,
            onChanged: (value) {
              setState(() {
                description = value;
              });
              // widget.callback({"description": value});

              project.description = value;
              widget.callback(project);
            },
          ),
        ],
      ),
    ));
  }
}
