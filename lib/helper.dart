import 'package:flutter/material.dart';

displayTextButton(context, String title, {callback}) {
  return (TextButton(
    child: Text(title),
    onPressed: () {
      if (callback != null) {
        callback();
      }
      Navigator.of(context).pop();
    },
  ));
}

displayTextInputField(context, String placeholder, callback) {
  return (TextFormField(
    initialValue: placeholder,
    onChanged: (value) => callback(value),
  ));
}

Future<void> showAlertDialogPopup(
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

Future<void> showTextInputDialogPopup(
    context, String title, Widget? content, List<Widget>? actions) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: actions,
      );
    },
  );
}
