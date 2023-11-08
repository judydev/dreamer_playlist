import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesTabView extends StatefulWidget {
  @override
  State<PreferencesTabView> createState() => _PreferencesTabViewState();
}

class _PreferencesTabViewState extends State<PreferencesTabView> {
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
