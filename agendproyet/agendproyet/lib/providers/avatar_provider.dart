import 'package:flutter/foundation.dart';

import '../models/avatar_config.dart';
import '../services/storage_service.dart';

class AvatarProvider extends ChangeNotifier {
  AvatarProvider(this._storage, {this.onSkinChanged});
  final StorageService _storage;

  /// Se llama al cambiar el tono de piel (para renovar las notificaciones,
  /// que eligen la ilustración según ese tono).
  final VoidCallback? onSkinChanged;

  AvatarConfig _config = const AvatarConfig();
  AvatarConfig get config => _config;

  void load() {
    _config = _storage.loadAvatar();
    notifyListeners();
  }

  void _update(AvatarConfig next) {
    _config = next;
    notifyListeners();
    _storage.saveAvatar(next);
  }

  void setSkin(int i) {
    if (i == _config.skin) return;
    _update(_config.copyWith(skin: i));
    onSkinChanged?.call();
  }

  void setHairStyle(int i) => _update(_config.copyWith(hairStyle: i));
  void setHairColor(int i) => _update(_config.copyWith(hairColor: i));
  void setBeardStyle(int i) => _update(_config.copyWith(beardStyle: i));
  void setBeardColor(int i) => _update(_config.copyWith(beardColor: i));
}
