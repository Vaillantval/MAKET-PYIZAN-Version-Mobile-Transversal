import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage.dart';

/// device_uid du terminal — généré une seule fois (UUID stable) et
/// conservé en stockage sécurisé. Il doit être communiqué à un
/// superadmin pour enregistrer le terminal côté admin avant que les
/// requêtes POS (header X-POS-Device) ne soient acceptées par le
/// backend.
final posDeviceUidProvider = StateNotifierProvider<PosDeviceNotifier, String?>((ref) {
  return PosDeviceNotifier(ref.read(secureStorageProvider));
});

class PosDeviceNotifier extends StateNotifier<String?> {
  final SecureStorage _secureStorage;

  PosDeviceNotifier(this._secureStorage) : super(null) {
    _initialiser();
  }

  Future<void> _initialiser() async {
    state = _secureStorage.deviceUidPos(); // même source que l'ApiClient
  }

  bool get estGenere => state != null && state!.isNotEmpty;

  /// Génère un nouvel identifiant (terminal remplacé, réinitialisé…).
  /// Nécessitera un nouvel enregistrement côté admin.
  Future<void> reinitialiser() async {
    final nouveau = const Uuid().v4();
    await _secureStorage.setString(AppConstants.keyPosDeviceUid, nouveau);
    state = nouveau;
  }
}
