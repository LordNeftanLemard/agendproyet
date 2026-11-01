import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/motivational_content.dart';
import '../models/alarm_model.dart';
import '../screens/motivation_screen.dart';

/// Notificaciones locales con imagen temática + frase motivacional.
///
/// - Android: la notificación expandida muestra el recorte 2:1 ("banner").
/// - iOS: adjunta la imagen vertical completa.
/// - Al pulsar la notificación se abre [MotivationScreen] con la imagen
///   vertical completa y la frase.
///
/// El contenido de una notificación programada es ESTÁTICO: se renueva
/// (frase, imagen, variante de piel) reprogramando al abrir la app o al
/// cambiar el tono de piel del avatar.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  /// Necesaria para navegar desde el toque de una notificación.
  static final navigatorKey = GlobalKey<NavigatorState>();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'agendproyet_habits';
  static const _channelName = 'Recordatorios de hábitos';

  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (e) {
      debugPrint('No se pudo resolver la zona horaria: $e');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (r) => _openFromPayload(r.payload),
    );
  }

  /// Si la app se abrió pulsando una notificación (estaba cerrada).
  /// Llamar tras el primer frame.
  Future<void> handleLaunchNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _openFromPayload(details!.notificationResponse?.payload);
    }
  }

  void _openFromPayload(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => MotivationScreen(
          phrase: data['phrase'] as String,
          imageAsset: data['image'] as String?,
          title: data['title'] as String? ?? 'Agendproyet',
        ),
      ));
    } catch (e) {
      debugPrint('Payload inválido: $e');
    }
  }

  /// Pide permisos de notificaciones (Android 13+/iOS) y de alarmas exactas.
  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidOk = await android?.requestNotificationsPermission();
    if (android != null && !(await android.canScheduleExactNotifications() ?? false)) {
      await android.requestExactAlarmsPermission();
    }
    final iosOk = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return androidOk ?? iosOk ?? true;
  }

  // ---------------------------------------------------------------- scheduling

  /// [skin] = índice de tono de piel del avatar, para elegir la variante
  /// de la ilustración que se le parezca.
  Future<void> scheduleAlarm(HabitAlarm alarm, {int skin = 1}) async {
    await cancelAlarm(alarm);
    if (!alarm.enabled) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await android?.canScheduleExactNotifications() ?? true;
    final mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (final weekday in alarm.weekdays) {
      final content = MotivationalContent.random(alarm.theme, skin: skin);
      final built = await _build(content, alarm);

      await _plugin.zonedSchedule(
        _notificationId(alarm.id, weekday),
        built.title,
        content.phrase,
        _nextInstanceOf(weekday, alarm.hour, alarm.minute),
        built.details,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: built.payload,
      );
    }
  }

  Future<void> cancelAlarm(HabitAlarm alarm) async {
    for (var d = 1; d <= 7; d++) {
      await _plugin.cancel(_notificationId(alarm.id, d));
    }
  }

  Future<void> rescheduleAll(List<HabitAlarm> alarms, {int skin = 1}) async {
    await _plugin.cancelAll();
    for (final a in alarms) {
      await scheduleAlarm(a, skin: skin);
    }
  }

  /// Notificación inmediata para probar el aspecto.
  Future<void> showTest(HabitTheme theme, {int skin = 1}) async {
    final content = MotivationalContent.random(theme, skin: skin);
    final fake = HabitAlarm(
        id: 0, label: '', hour: 0, minute: 0, weekdays: const {}, theme: theme);
    final built = await _build(content, fake);
    await _plugin.show(
        999999999, built.title, content.phrase, built.details, payload: built.payload);
  }

  // ------------------------------------------------------------------ helpers

  int _notificationId(int alarmId, int weekday) => alarmId * 10 + weekday;

  tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (date.weekday != weekday || !date.isAfter(now)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<({String title, NotificationDetails details, String payload})> _build(
      MotivationalContent content, HabitAlarm alarm) async {
    final title = alarm.label.isEmpty
        ? '${alarm.theme.emoji} ${alarm.theme.label}'
        : alarm.label;

    final bannerPath =
        content.image == null ? null : await _assetToFile(content.image!.banner);
    final fullPath =
        content.image == null ? null : await _assetToFile(content.image!.full);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Recordatorios con frases motivacionales',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      styleInformation: bannerPath == null
          ? BigTextStyleInformation(content.phrase)
          : BigPictureStyleInformation(
              FilePathAndroidBitmap(bannerPath),
              contentTitle: title,
              summaryText: content.phrase,
            ),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      attachments:
          fullPath == null ? null : [DarwinNotificationAttachment(fullPath)],
    );

    return (
      title: title,
      details: NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode({
        'title': title,
        'phrase': content.phrase,
        'image': content.image?.full,
      }),
    );
  }

  /// Las notificaciones necesitan un archivo real: copiamos el asset a disco.
  /// Si la imagen no existe, la notificación sale solo con texto.
  Future<String?> _assetToFile(String asset) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/${asset.split('/').last}');
      if (!await file.exists()) {
        final data = await rootBundle.load(asset);
        await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }
      return file.path;
    } catch (e) {
      debugPrint('Sin imagen para la notificación ($asset): $e');
      return null;
    }
  }
}
