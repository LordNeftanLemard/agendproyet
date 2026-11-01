import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/avatar_config.dart';

/// Avatar por capas: piel -> barba -> cabello.
///
/// Cada capa intenta cargar un PNG transparente del mismo tamaño:
///   assets/avatar/skin/skin_<i>.png      (a color)
///   assets/avatar/beard/beard_<i>.png    (silueta blanca, se tiñe con el color)
///   assets/avatar/hair/hair_<i>.png      (silueta blanca, se tiñe con el color)
/// Si el PNG no existe, dibuja una versión vectorial de reemplazo, así la
/// pantalla funciona desde el primer día sin arte final.
class LayeredAvatar extends StatelessWidget {
  const LayeredAvatar({super.key, required this.config, this.size = 220});

  final AvatarConfig config;
  final double size;

  @override
  Widget build(BuildContext context) {
    final skin = AvatarPalette.skinTones[config.skin];
    final hair = AvatarPalette.hairColors[config.hairColor];
    final beard = AvatarPalette.hairColors[config.beardColor];
    final bg = Theme.of(context).colorScheme.primaryContainer;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Layer(
              asset: 'assets/avatar/skin/skin_${config.skin}.png',
              painter: _SkinPainter(skin),
            ),
            if (config.beardStyle > 0)
              _Layer(
                asset: 'assets/avatar/beard/beard_${config.beardStyle}.png',
                tint: beard,
                painter: _BeardPainter(config.beardStyle, beard),
              ),
            if (config.hairStyle > 0)
              _Layer(
                asset: 'assets/avatar/hair/hair_${config.hairStyle}.png',
                tint: hair,
                painter: _HairPainter(config.hairStyle, hair),
              ),
          ],
        ),
      ),
    );
  }
}

class _Layer extends StatelessWidget {
  const _Layer({required this.asset, required this.painter, this.tint});

  final String asset;
  final CustomPainter painter;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      color: tint,
      colorBlendMode: tint == null ? null : BlendMode.srcIn,
      errorBuilder: (_, __, ___) => CustomPaint(painter: painter),
    );
  }
}

// ---------------------------------------------------------------------------
// Painters de reemplazo (lienzo lógico de 100x100)
// ---------------------------------------------------------------------------

Paint _fill(Color c) => Paint()..color = c;

class _SkinPainter extends CustomPainter {
  _SkinPainter(this.skin);
  final Color skin;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    const dark = Color(0xFF2B2B2B);

    canvas.drawOval(const Rect.fromLTWH(14, 78, 72, 50), _fill(const Color(0xFF2E7D6B))); // torso
    canvas.drawRect(const Rect.fromLTWH(43, 66, 14, 18), _fill(skin)); // cuello
    canvas.drawOval(Rect.fromCenter(center: const Offset(25, 47), width: 7, height: 12), _fill(skin));
    canvas.drawOval(Rect.fromCenter(center: const Offset(75, 47), width: 7, height: 12), _fill(skin));
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 45), width: 48, height: 58), _fill(skin)); // cabeza
    canvas.drawCircle(const Offset(41, 46), 2.4, _fill(dark));
    canvas.drawCircle(const Offset(59, 46), 2.4, _fill(dark));
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(50, 58), width: 12, height: 8),
      0,
      math.pi,
      false,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SkinPainter old) => old.skin != skin;
}

class _HairPainter extends CustomPainter {
  _HairPainter(this.style, this.color);
  final int style;
  final Color color;

  void _cap(Canvas canvas, Paint p) {
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, 100, 37));
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 43), width: 54, height: 64), p);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final p = _fill(color);
    switch (style) {
      case 1: // corto
        _cap(canvas, p);
      case 2: // rizado
        _cap(canvas, p);
        for (var i = 0; i < 8; i++) {
          final edge = (i == 0 || i == 7) ? 10.0 : (i == 1 || i == 6) ? 4.0 : 0.0;
          canvas.drawCircle(Offset(26 + i * 6.8, 26 + edge), 9, p);
        }
      case 3: // largo
        _cap(canvas, p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(22, 30, 11, 52), const Radius.circular(5)), p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(67, 30, 11, 52), const Radius.circular(5)), p);
      case 4: // mohicano
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(43, 6, 14, 32), const Radius.circular(6)), p);
    }
  }

  @override
  bool shouldRepaint(_HairPainter old) => old.style != style || old.color != color;
}

class _BeardPainter extends CustomPainter {
  _BeardPainter(this.style, this.color);
  final int style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final p = _fill(color);
    switch (style) {
      case 1: // candado: bigote + mentón
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(40, 55, 20, 4), const Radius.circular(2)), p);
        canvas.drawOval(Rect.fromCenter(center: const Offset(50, 70), width: 14, height: 10), p);
      case 2: // perilla
        canvas.drawOval(Rect.fromCenter(center: const Offset(50, 69), width: 9, height: 11), p);
      case 3: // completa
        canvas.save();
        canvas.clipRect(const Rect.fromLTWH(0, 55, 100, 45));
        canvas.drawOval(Rect.fromCenter(center: const Offset(50, 45), width: 52, height: 62), p);
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BeardPainter old) => old.style != style || old.color != color;
}
