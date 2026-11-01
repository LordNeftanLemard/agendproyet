import 'package:flutter/foundation.dart';

import '../models/alarm_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class AlarmsProvider extends ChangeNotifier {
  AlarmsProvider(this._storage);
  final StorageService _storage;

  List<HabitAlarm> _alarms = [];
  List<HabitAlarm> get alarms => List.unmodifiable(_alarms);
  int get activeCount => _alarms.where((a) => a.enabled).length;

  int get _skin => _storage.loadAvatar().skin;

  Future<void> load() async {
    _alarms = _storage.loadAlarms();
    _sort();
    notifyListeners();
    await refreshNotifications();
  }

  /// Reprograma todo: renueva frase e imagen y aplica el tono de piel actual.
  Future<void> refreshNotifications() =>
      NotificationService.instance.rescheduleAll(_alarms, skin: _skin);

  Future<void> upsert(HabitAlarm alarm) async {
    final i = _alarms.indexWhere((a) => a.id == alarm.id);
    if (i >= 0) {
      _alarms[i] = alarm;
    } else {
      _alarms.add(alarm);
    }
    _sort();
    notifyListeners();
    await _storage.saveAlarms(_alarms);
    await NotificationService.instance.scheduleAlarm(alarm, skin: _skin);
  }

  Future<void> toggle(HabitAlarm alarm, bool enabled) =>
      upsert(alarm.copyWith(enabled: enabled));

  Future<void> remove(HabitAlarm alarm) async {
    _alarms.removeWhere((a) => a.id == alarm.id);
    notifyListeners();
    await _storage.saveAlarms(_alarms);
    await NotificationService.instance.cancelAlarm(alarm);
  }

  void _sort() => _alarms.sort(
      (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
}
