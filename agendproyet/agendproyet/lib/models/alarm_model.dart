import 'package:flutter/material.dart';
import '../data/motivational_content.dart';

/// Alarma recurrente. [weekdays] usa DateTime.weekday: 1 = Lunes ... 7 = Domingo.
@immutable
class HabitAlarm {
  const HabitAlarm({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    required this.weekdays,
    this.enabled = true,
    this.theme = HabitTheme.productivity,
  });

  /// Id base < 100.000.000 para que id*10+día quepa en un int de 32 bits.
  factory HabitAlarm.create({
    required String label,
    required TimeOfDay time,
    required Set<int> weekdays,
    required HabitTheme theme,
  }) =>
      HabitAlarm(
        id: DateTime.now().millisecondsSinceEpoch % 100000000,
        label: label,
        hour: time.hour,
        minute: time.minute,
        weekdays: weekdays,
        theme: theme,
      );

  final int id;
  final String label;
  final int hour;
  final int minute;
  final Set<int> weekdays;
  final bool enabled;
  final HabitTheme theme;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  static const dayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  String get weekdaysLabel {
    if (weekdays.length == 7) return 'Todos los días';
    if (weekdays.length == 5 && !weekdays.contains(6) && !weekdays.contains(7)) {
      return 'Lunes a viernes';
    }
    final sorted = weekdays.toList()..sort();
    return sorted.map((d) => dayNames[d - 1]).join(' · ');
  }

  HabitAlarm copyWith({
    String? label,
    int? hour,
    int? minute,
    Set<int>? weekdays,
    bool? enabled,
    HabitTheme? theme,
  }) =>
      HabitAlarm(
        id: id,
        label: label ?? this.label,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        weekdays: weekdays ?? this.weekdays,
        enabled: enabled ?? this.enabled,
        theme: theme ?? this.theme,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'hour': hour,
        'minute': minute,
        'weekdays': weekdays.toList(),
        'enabled': enabled,
        'theme': theme.name,
      };

  factory HabitAlarm.fromJson(Map<String, dynamic> j) => HabitAlarm(
        id: j['id'] as int,
        label: (j['label'] as String?) ?? '',
        hour: j['hour'] as int,
        minute: j['minute'] as int,
        weekdays: ((j['weekdays'] as List).cast<int>()).toSet(),
        enabled: (j['enabled'] as bool?) ?? true,
        theme: HabitTheme.values.firstWhere(
          (t) => t.name == j['theme'],
          orElse: () => HabitTheme.productivity,
        ),
      );
}
