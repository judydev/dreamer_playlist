// Reference: https://github.com/dxvid-pts/miniplayer

import 'package:dreamer_playlist/components/miniplayer/miniplayer.dart';

extension SelectedColorExtension on PanelState {
  int get heightCode {
    switch (this) {
      case PanelState.MIN:
        return -1;
      case PanelState.MAX:
        return -2;
      case PanelState.DISMISS:
        return -3;
      default:
        return -1;
    }
  }
}

double valueFromPercentageInRange(
    {required final double min, max, percentage}) {
  return percentage * (max - min) + min;
}

double percentageFromValueInRange({required final double min, max, value}) {
  return (value - min) / (max - min);
}

double borderDouble(
    {required double minRange,
    required double maxRange,
    required double value}) {
  if (value > maxRange) return maxRange;
  if (value < minRange) return minRange;
  return value;
}
