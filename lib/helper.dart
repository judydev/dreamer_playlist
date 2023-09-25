import 'package:flutter/material.dart';

displayTextButton(context, String title) {
  return (TextButton(
    child: Text(title),
    onPressed: () {
      Navigator.of(context).pop();
    },
  ));
}

Future<void> showDialogPopup(
    context, String title, Widget? content, List<Widget>? actions) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: actions,
      );
    },
  );
}
