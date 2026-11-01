import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/alarms_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/layered_avatar.dart';
import 'alarms_screen.dart';
import 'avatar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<AvatarProvider>().config;
    final active = context.watch<AlarmsProvider>().activeCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Agendproyet')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: LayeredAvatar(config: avatar, size: 180)),
          const SizedBox(height: 12),
          Center(
            child: Text('¡Hola! Vamos por tus hábitos de hoy.',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.face_retouching_natural),
              title: const Text('Personalizar avatar'),
              subtitle: const Text('Piel, cabello y barba'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AvatarScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Mis alarmas'),
              subtitle: Text(active == 0
                  ? 'Aún no tienes alarmas activas'
                  : '$active alarma(s) activa(s)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AlarmsScreen())),
            ),
          ),
        ],
      ),
    );
  }
}
