import 'package:flutter/material.dart';

class FutureBuilderWrapper extends StatelessWidget {
  final Future future;
  final Widget Function(BuildContext, AsyncSnapshot<dynamic>) buildFunction;

  FutureBuilderWrapper(this.future, this.buildFunction);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Text("Loading...");
        } else if (snapshot.hasError) {
          return ErrorView(snapshot.error.toString());
        } else {
          return buildFunction(context, snapshot);
        }
      },
    );
  }
}

class ErrorView extends StatelessWidget {
  final String errorMessage;
  ErrorView(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Error: $errorMessage'),
          ),
        ]);
  }
}
