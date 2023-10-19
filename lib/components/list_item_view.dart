import 'package:flutter/material.dart';

class ListItemView extends StatelessWidget {
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String title;
  final void Function()? onTapAction;
  ListItemView(
      {this.leadingIcon,
      this.trailingIcon,
      required this.title,
      this.onTapAction});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: BeveledRectangleBorder(),
        child: ListTile(
            leading: leadingIcon,
            trailing: trailingIcon,
            title: Text(title),
            contentPadding: EdgeInsets.all(10),
            onTap: onTapAction));
  }
}
