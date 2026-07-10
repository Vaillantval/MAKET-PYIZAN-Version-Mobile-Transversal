import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';

/// device_uid du terminal appairé (null si non appairé).
final posDeviceUidProvider = StateNotifierProvider<PosDeviceNotifier, String?>((ref) {
  return PosDeviceNotifier(ref.read(localStorageProvider));
});

class PosDeviceNotifier extends StateNotifier<String?> {
  final LocalStorage _storage;

  PosDeviceNotifier(this._storage)
      : super(_storage.getString(AppConstants.keyPosDeviceUid));

  bool get isAppaire => state != null && state!.isNotEmpty;

  Future<void> appairer(String deviceUid) async {
    await _storage.setString(AppConstants.keyPosDeviceUid, deviceUid);
    state = deviceUid;
  }

  Future<void> desappairer() async {
    await _storage.remove(AppConstants.keyPosDeviceUid);
    state = null;
  }
}
