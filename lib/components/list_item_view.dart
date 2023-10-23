import 'package:flutter/material.dart';

class ListTileView extends StatelessWidget {
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String title;
  final void Function()? onTapCallback;
  ListTileView(
      {this.leadingIcon,
      this.trailingIcon,
      required this.title,
      this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    return ListTile(
            leading: leadingIcon,
            trailing: trailingIcon,
            title: Text(title),
            contentPadding: EdgeInsets.all(10),
        onTap: onTapCallback);
  }
}
