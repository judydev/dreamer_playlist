import 'package:flutter/material.dart';

class PopupMenuTile extends StatelessWidget {
  const PopupMenuTile({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
        ),
        const SizedBox(
          width: 8,
        ),
        Icon(
          icon,
        ),
      ],
    );
  }
}
