import 'dart:math';

/// Temas de hábito. Cada tema tiene frases y una o varias ilustraciones.
enum HabitTheme {
  fitness('Ejercicio', '💪'),
  mindfulness('Mente', '🧘'),
  productivity('Productividad', '🚀'),
  lifestyle('Estilo de vida', '✨'),
  study('Estudio', '📚'),
  health('Salud', '🥗');

  const HabitTheme(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Una ilustración temática.
///  - [full]: versión vertical completa (pantalla al pulsar la notificación, iOS).
///  - [banner]: recorte 2:1 pensado para la notificación expandida de Android.
///  - [skins]: tonos de piel del avatar (AvatarPalette.skinTones) para los que
///    aplica. null = sirve para cualquiera.
class ThemeImage {
  const ThemeImage(this.name, {this.skins});
  final String name;
  final Set<int>? skins;

  String get full => 'assets/notifications/full/$name.jpg';
  String get banner => 'assets/notifications/banner/$name.jpg';
}

class MotivationalContent {
  const MotivationalContent({required this.phrase, this.image});
  final String phrase;
  final ThemeImage? image;

  static final _rng = Random();

  /// Para añadir arte: sube el JPG a assets/notifications/full y banner
  /// y regístralo aquí. Los temas sin imagen salen solo con texto.
  static const Map<HabitTheme, List<ThemeImage>> _images = {
    HabitTheme.fitness: [
      ThemeImage('fitness_1', skins: {0, 1, 2}), // piel clara / trigueña
      ThemeImage('fitness_2', skins: {3, 4}), // piel oscura
    ],
    HabitTheme.mindfulness: [ThemeImage('mindfulness_1')],
    HabitTheme.productivity: [ThemeImage('productivity_1')],
    HabitTheme.lifestyle: [ThemeImage('lifestyle_1')],
  };

  static const Map<HabitTheme, List<String>> _phrases = {
    HabitTheme.fitness: [
      'Llueve afuera. Adentro, tú decides.',
      'Hoy sudas, mañana lo agradeces.',
      'No tiene que ser perfecto, tiene que ser hoy.',
      'Cada repetición te acerca a quien quieres ser.',
    ],
    HabitTheme.mindfulness: [
      'Respira hondo. Este momento es todo lo que tienes.',
      'La calma también es productiva.',
      'Una noche tranquila también es un logro.',
      'Cinco minutos contigo valen más que cinco horas de ruido.',
    ],
    HabitTheme.productivity: [
      'Un paso pequeño hoy vale más que un plan perfecto mañana.',
      'Enfócate en lo importante, no en lo urgente.',
      'Construye en silencio. El resultado hará el ruido.',
      'Empieza ahora. Ajusta sobre la marcha.',
    ],
    HabitTheme.lifestyle: [
      'Creo que me gusta esta pequeña vida.',
      'Diseña los días que quieres recordar.',
      'El estilo es hábito: se construye todos los días.',
      'Cuida los detalles. Los detalles te cuidan a ti.',
    ],
    HabitTheme.study: [
      'Aprender un poco cada día supera estudiar mucho una vez.',
      'Lo que hoy cuesta, mañana es tu ventaja.',
      'Abre el libro: lo difícil es empezar.',
      'Tu yo del futuro te está mirando. Hazlo sentir orgulloso.',
    ],
    HabitTheme.health: [
      'Cuidarte es la mejor inversión a largo plazo.',
      'Una buena decisión ahora, un gran día después.',
      'Agua, descanso y constancia. Así de simple.',
      'Tu salud es tu proyecto más importante.',
    ],
  };

  /// Elige frase al azar e imagen compatible con el tono de piel del avatar.
  static MotivationalContent random(HabitTheme theme, {int skin = 1}) {
    final phrases = _phrases[theme]!;
    final candidates = (_images[theme] ?? const <ThemeImage>[])
        .where((i) => i.skins == null || i.skins!.contains(skin))
        .toList();
    return MotivationalContent(
      phrase: phrases[_rng.nextInt(phrases.length)],
      image: candidates.isEmpty ? null : candidates[_rng.nextInt(candidates.length)],
    );
  }
}
