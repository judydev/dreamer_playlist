import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsTabView extends StatefulWidget {
  @override
  State<SettingsTabView> createState() => _SettingsTabViewState();
}

class _SettingsTabViewState extends State<SettingsTabView> {
  late AppStateDataProvider appStateDataProvider;
  late Future<Map<String, dynamic>> _getSettings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    appStateDataProvider = Provider.of<AppStateDataProvider>(context);
    _getSettings = appStateDataProvider.getAppStates();
  }

  @override
  Widget build(BuildContext context) {
    return Text("Settings View");
  }
}
