import 'package:flutter/material.dart';

/// Catálogo de opciones del avatar. Los índices se guardan en la config.
class AvatarPalette {
  AvatarPalette._();

  static const skinTones = <Color>[
    Color(0xFFFFE0C7),
    Color(0xFFF1C27D),
    Color(0xFFC68642),
    Color(0xFF8D5524),
    Color(0xFF5C3A1E),
  ];

  static const hairColors = <Color>[
    Color(0xFF1B1B1B),
    Color(0xFF4B2E1E),
    Color(0xFFB5651D),
    Color(0xFFE5C07B),
    Color(0xFFB0B0B0),
    Color(0xFFC0392B),
  ];

  /// El índice 0 significa "sin capa".
  static const hairStyles = <String>['Calvo', 'Corto', 'Rizado', 'Largo', 'Mohicano'];
  static const beardStyles = <String>['Sin barba', 'Candado', 'Perilla', 'Completa'];
}

@immutable
class AvatarConfig {
  const AvatarConfig({
    this.skin = 1,
    this.hairStyle = 1,
    this.hairColor = 1,
    this.beardStyle = 0,
    this.beardColor = 1,
  });

  final int skin;
  final int hairStyle;
  final int hairColor;
  final int beardStyle;
  final int beardColor;

  AvatarConfig copyWith({
    int? skin,
    int? hairStyle,
    int? hairColor,
    int? beardStyle,
    int? beardColor,
  }) =>
      AvatarConfig(
        skin: skin ?? this.skin,
        hairStyle: hairStyle ?? this.hairStyle,
        hairColor: hairColor ?? this.hairColor,
        beardStyle: beardStyle ?? this.beardStyle,
        beardColor: beardColor ?? this.beardColor,
      );

  Map<String, dynamic> toJson() => {
        'skin': skin,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'beardStyle': beardStyle,
        'beardColor': beardColor,
      };

  factory AvatarConfig.fromJson(Map<String, dynamic> j) {
    int pick(String k, int max, int def) =>
        ((j[k] as num?)?.toInt() ?? def).clamp(0, max - 1);
    return AvatarConfig(
      skin: pick('skin', AvatarPalette.skinTones.length, 1),
      hairStyle: pick('hairStyle', AvatarPalette.hairStyles.length, 1),
      hairColor: pick('hairColor', AvatarPalette.hairColors.length, 1),
      beardStyle: pick('beardStyle', AvatarPalette.beardStyles.length, 0),
      beardColor: pick('beardColor', AvatarPalette.hairColors.length, 1),
    );
  }
}
