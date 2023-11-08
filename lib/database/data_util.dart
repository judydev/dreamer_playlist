import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/models/app_state.dart';

class DataUtil {
  static Future<Map<String, dynamic>> loadInitialData() async {
    Map<String, dynamic> res = {};
    String? currentTab =
        await AppStateDataProvider().getAppStateByKey(AppStateKey.currentTab);

    AppStates appStates = AppStates();
    appStates.currentTab = currentTab;
    GetitUtil.appStates = appStates;

    return res;
  }
}
