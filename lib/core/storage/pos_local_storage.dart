import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final posLocalStorageProvider = Provider<PosLocalStorage>(
  (_) => throw UnimplementedError('Init in main.dart'),
);

/// Persistance locale POS (session de caisse + historique des ventes)
/// via Hive — survit au redémarrage de l'app, sans nécessiter de
/// TypeAdapter généré (on stocke uniquement des Map JSON-compatibles).
class PosLocalStorage {
  final Box _sessionBox;
  final Box _salesBox;
  static const String _sessionKey = 'current';

  PosLocalStorage(this._sessionBox, this._salesBox);

  // ── Session de caisse ────────────────────────────────────────────

  Future<void> saveSession(Map<String, dynamic> session) =>
      _sessionBox.put(_sessionKey, session);

  Map<String, dynamic>? getSession() {
    final raw = _sessionBox.get(_sessionKey);
    if (raw == null) return null;
    return _deepMap(raw);
  }

  Future<void> clearSession() => _sessionBox.delete(_sessionKey);

  // ── Historique des ventes ────────────────────────────────────────

  // La clé est 'idempotency_key' (snake_case) : c'est ce que produit
  // PosSale.toJson() via @JsonKey — pas le nom Dart camelCase.
  Future<void> saveSale(Map<String, dynamic> sale) =>
      _salesBox.put(sale['idempotency_key'] as String, sale);

  List<Map<String, dynamic>> getAllSales() => _salesBox.values
      .map((e) => _deepMap(e))
      .toList();

  int countBySyncStatus(String syncStatus) => getAllSales()
      .where((s) => s['syncStatus'] == syncStatus)
      .length;

  // ── Helpers ───────────────────────────────────────────────────────

  static Map<String, dynamic> _deepMap(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), _deepValue(val)));
    }
    return <String, dynamic>{};
  }

  static dynamic _deepValue(dynamic v) {
    if (v is Map) return _deepMap(v);
    if (v is List) return v.map(_deepValue).toList();
    return v;
  }
}
