import 'package:flutter/material.dart';

class PopupMenuTile extends StatelessWidget {
  const PopupMenuTile({this.icon, required this.title});
  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    List<Widget> menuItems = [Text(title)];
    if (icon != null) {
      menuItems.addAll([const SizedBox(width: 8), Icon(icon)]);
    }
    
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: menuItems,
    );
  }
}
