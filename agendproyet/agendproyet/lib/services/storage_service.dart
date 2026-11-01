import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm_model.dart';
import '../models/avatar_config.dart';

class StorageService {
  StorageService._(this._prefs);
  final SharedPreferences _prefs;

  static Future<StorageService> create() async =>
      StorageService._(await SharedPreferences.getInstance());

  AvatarConfig loadAvatar() {
    final raw = _prefs.getString('avatar');
    if (raw == null) return const AvatarConfig();
    try {
      return AvatarConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AvatarConfig();
    }
  }

  Future<void> saveAvatar(AvatarConfig c) =>
      _prefs.setString('avatar', jsonEncode(c.toJson()));

  List<HabitAlarm> loadAlarms() {
    final raw = _prefs.getString('alarms');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => HabitAlarm.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAlarms(List<HabitAlarm> alarms) =>
      _prefs.setString('alarms', jsonEncode(alarms.map((a) => a.toJson()).toList()));
}
