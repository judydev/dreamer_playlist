import 'package:flutter/material.dart';

TextButton displayTextButton(BuildContext context, String title,
    {Function? callback}) {
  return (TextButton(
      onPressed: () {
      if (callback != null) {
        callback();
      }
      Navigator.of(context).pop();
    },
      child: Text(title)
  ));
}

Future<void> showAlertDialogPopup(
    context, String title, Widget? content, List<Widget>? actions) async {
  return showAdaptiveDialog<void>(
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
