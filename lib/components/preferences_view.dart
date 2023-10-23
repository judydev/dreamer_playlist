import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesView extends StatefulWidget {
  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  late AppStateDataProvider appStateDataProvider;
  late Future<Map<String, dynamic>> _getPreferences;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    appStateDataProvider = Provider.of<AppStateDataProvider>(context);
    _getPreferences = appStateDataProvider.getAppStates();
  }

  @override
  Widget build(BuildContext context) {
    return Text("Preferences View");
  }
}
