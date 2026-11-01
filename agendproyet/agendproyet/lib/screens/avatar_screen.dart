import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/avatar_config.dart';
import '../providers/avatar_provider.dart';
import '../widgets/layered_avatar.dart';
import '../widgets/option_pickers.dart';

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvatarProvider>();
    final c = provider.config;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tu avatar')),
        body: Column(
          children: [
            const SizedBox(height: 16),
            LayeredAvatar(config: c, size: 200),
            const SizedBox(height: 8),
            const TabBar(tabs: [
              Tab(icon: Icon(Icons.palette_outlined), text: 'Piel'),
              Tab(icon: Icon(Icons.content_cut), text: 'Cabello'),
              Tab(icon: Icon(Icons.face_6), text: 'Barba'),
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  _Section(children: [
                    const _Title('Tono de piel'),
                    ColorSwatchPicker(
                      colors: AvatarPalette.skinTones,
                      selected: c.skin,
                      onSelected: provider.setSkin,
                    ),
                  ]),
                  _Section(children: [
                    const _Title('Estilo'),
                    StyleChips(
                      labels: AvatarPalette.hairStyles,
                      selected: c.hairStyle,
                      onSelected: provider.setHairStyle,
                    ),
                    const SizedBox(height: 24),
                    const _Title('Color'),
                    ColorSwatchPicker(
                      colors: AvatarPalette.hairColors,
                      selected: c.hairColor,
                      onSelected: provider.setHairColor,
                    ),
                  ]),
                  _Section(children: [
                    const _Title('Estilo'),
                    StyleChips(
                      labels: AvatarPalette.beardStyles,
                      selected: c.beardStyle,
                      onSelected: provider.setBeardStyle,
                    ),
                    const SizedBox(height: 24),
                    const _Title('Color'),
                    ColorSwatchPicker(
                      colors: AvatarPalette.hairColors,
                      selected: c.beardColor,
                      onSelected: provider.setBeardColor,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: children,
      );
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}
