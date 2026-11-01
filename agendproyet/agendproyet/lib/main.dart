import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/alarms_provider.dart';
import 'providers/avatar_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  final storage = await StorageService.create();

  final alarms = AlarmsProvider(storage);
  final avatar = AvatarProvider(storage, onSkinChanged: alarms.refreshNotifications)
    ..load();
  alarms.load(); // también reprograma las notificaciones (frases nuevas)

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: avatar),
        ChangeNotifierProvider.value(value: alarms),
      ],
      child: const AgendproyetApp(),
    ),
  );

  // Si la app se abrió desde una notificación, mostrar su pantalla.
  WidgetsBinding.instance.addPostFrameCallback(
      (_) => NotificationService.instance.handleLaunchNotification());
}

class AgendproyetApp extends StatelessWidget {
  const AgendproyetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agendproyet',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
