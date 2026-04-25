import 'package:flutter/services.dart';
import '../providers/settings_provider.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  SettingsProvider? _settingsProvider;

  void init(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  void _vibrate(Future<void> Function() hapticCall) {
    if (_settingsProvider?.hapticFeedback ?? true) {
      hapticCall();
    }
  }

  void light() => _vibrate(HapticFeedback.lightImpact);
  void medium() => _vibrate(HapticFeedback.mediumImpact);
  void heavy() => _vibrate(HapticFeedback.heavyImpact);
  void selection() => _vibrate(HapticFeedback.selectionClick);
  void error() => _vibrate(HapticFeedback.vibrate);
}
