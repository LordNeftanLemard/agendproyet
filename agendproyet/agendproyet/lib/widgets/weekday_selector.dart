import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

/// Selector L M X J V S D (1 = lunes ... 7 = domingo).
class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({super.key, required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var d = 1; d <= 7; d++)
              InkResponse(
                onTap: () {
                  final next = {...selected};
                  next.contains(d) ? next.remove(d) : next.add(d);
                  onChanged(next);
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      selected.contains(d) ? scheme.primary : scheme.surfaceContainerHighest,
                  child: Text(
                    HabitAlarm.dayLetters[d - 1],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected.contains(d) ? scheme.onPrimary : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => onChanged({1, 2, 3, 4, 5}),
              child: const Text('L-V'),
            ),
            TextButton(
              onPressed: () => onChanged({6, 7}),
              child: const Text('Fin de semana'),
            ),
            TextButton(
              onPressed: () => onChanged({1, 2, 3, 4, 5, 6, 7}),
              child: const Text('L-D'),
            ),
          ],
        ),
      ],
    );
  }
}
