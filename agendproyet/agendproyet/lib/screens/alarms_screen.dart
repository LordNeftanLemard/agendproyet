import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/motivational_content.dart';
import '../models/alarm_model.dart';
import '../providers/alarms_provider.dart';
import '../providers/avatar_provider.dart';
import '../services/notification_service.dart';
import '../widgets/weekday_selector.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => NotificationService.instance.requestPermissions());
  }

  Future<void> _openEditor([HabitAlarm? alarm]) async {
    final result = await showModalBottomSheet<HabitAlarm>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AlarmEditorSheet(alarm: alarm),
    );
    if (result != null && mounted) {
      await context.read<AlarmsProvider>().upsert(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlarmsProvider>();
    final alarms = provider.alarms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarmas'),
        actions: [
          IconButton(
            tooltip: 'Probar notificación',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () async {
              final ok = await NotificationService.instance.requestPermissions();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Activa los permisos de notificaciones en Ajustes.')));
                return;
              }
              await NotificationService.instance.showTest(
                HabitTheme.fitness,
                skin: context.read<AvatarProvider>().config.skin,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva alarma'),
      ),
      body: alarms.isEmpty
          ? const Center(child: Text('Crea tu primera alarma recurrente'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: alarms.length,
              itemBuilder: (context, i) {
                final a = alarms[i];
                return Dismissible(
                  key: ValueKey(a.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_outline),
                  ),
                  onDismissed: (_) => provider.remove(a),
                  child: ListTile(
                    onTap: () => _openEditor(a),
                    title: Text(
                      a.time.format(context),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: Text(
                        '${a.theme.emoji} ${a.label.isEmpty ? a.theme.label : a.label}\n${a.weekdaysLabel}'),
                    isThreeLine: true,
                    trailing: Switch(
                      value: a.enabled,
                      onChanged: (v) => provider.toggle(a, v),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AlarmEditorSheet extends StatefulWidget {
  const AlarmEditorSheet({super.key, this.alarm});
  final HabitAlarm? alarm;

  @override
  State<AlarmEditorSheet> createState() => _AlarmEditorSheetState();
}

class _AlarmEditorSheetState extends State<AlarmEditorSheet> {
  late TimeOfDay _time;
  late Set<int> _days;
  late HabitTheme _theme;
  late final TextEditingController _label;

  @override
  void initState() {
    super.initState();
    final a = widget.alarm;
    _time = a?.time ?? const TimeOfDay(hour: 7, minute: 0);
    _days = {...(a?.weekdays ?? {1, 2, 3, 4, 5, 6, 7})};
    _theme = a?.theme ?? HabitTheme.productivity;
    _label = TextEditingController(text: a?.label ?? '');
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _save() {
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Elige al menos un día de la semana.')));
      return;
    }
    final existing = widget.alarm;
    final result = existing == null
        ? HabitAlarm.create(
            label: _label.text.trim(), time: _time, weekdays: _days, theme: _theme)
        : existing.copyWith(
            label: _label.text.trim(),
            hour: _time.hour,
            minute: _time.minute,
            weekdays: _days,
            theme: _theme,
            enabled: true,
          );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: TextButton(
                onPressed: _pickTime,
                child: Text(_time.format(context),
                    style: Theme.of(context).textTheme.displayMedium),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                hintText: 'Ej. Salir a correr',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text('Repetir', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            WeekdaySelector(selected: _days, onChanged: (d) => setState(() => _days = d)),
            const SizedBox(height: 12),
            Text('Tema de la notificación',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in HabitTheme.values)
                  ChoiceChip(
                    label: Text('${t.emoji} ${t.label}'),
                    selected: _theme == t,
                    onSelected: (_) => setState(() => _theme = t),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Guardar')),
            ),
          ],
        ),
      ),
    );
  }
}
