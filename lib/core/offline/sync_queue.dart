import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(ref.read(localStorageProvider));
});

/// Type d'action en attente de synchronisation
enum SyncActionType {
  panierAjouter,
  panierModifier,
  panierRetirer,
  panierVider,
  commander,
  confirmerCommande,
  soumettrePreuve,
  confirmerParticipation,
  updateProfil,
  createProduit,
  updateProduit,
  deleteProduit,
  contactMessage,
  posSale,
}

class SyncAction {
  final String         id;
  final SyncActionType type;
  final String         endpoint;
  final String         method;     // POST, PATCH, DELETE
  final Map<String, dynamic> payload;
  final int            retries;
  final DateTime       createdAt;
  final String?        localId;    // ID local pour l'UI avant sync

  SyncAction({
    required this.type,
    required this.endpoint,
    required this.method,
    required this.payload,
    this.localId,
    String? id,
    this.retries = 0,
    DateTime? createdAt,
  })  : id        = id        ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id':        id,
    'type':      type.name,
    'endpoint':  endpoint,
    'method':    method,
    'payload':   payload,
    'retries':   retries,
    'createdAt': createdAt.toIso8601String(),
    'localId':   localId,
  };

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
    id:       json['id'] as String,
    type:     SyncActionType.values.firstWhere(
                (e) => e.name == json['type'],
                orElse: () => SyncActionType.commander,
              ),
    endpoint: json['endpoint'] as String,
    method:   json['method'] as String,
    payload:  Map<String, dynamic>.from(json['payload'] as Map),
    retries:  json['retries'] as int? ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String),
    localId:  json['localId'] as String?,
  );

  SyncAction copyWith({int? retries}) => SyncAction(
    id:        id,
    type:      type,
    endpoint:  endpoint,
    method:    method,
    payload:   payload,
    retries:   retries ?? this.retries,
    createdAt: createdAt,
    localId:   localId,
  );
}

class SyncQueue {
  final LocalStorage _storage;
  static const String _key = AppConstants.keySyncQueue;

  SyncQueue(this._storage);

  List<SyncAction> getAll() {
    final list = _storage.getJsonList(_key);
    if (list == null) return [];
    return list
        .map((e) => SyncAction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(SyncAction action) async {
    final queue = getAll();
    queue.add(action);
    await _save(queue);
  }

  Future<void> remove(String id) async {
    final queue = getAll().where((a) => a.id != id).toList();
    await _save(queue);
  }

  Future<void> incrementRetry(String id) async {
    final queue = getAll().map((a) {
      if (a.id == id) return a.copyWith(retries: a.retries + 1);
      return a;
    }).toList();
    await _save(queue);
  }

  Future<void> clear() async => _storage.remove(_key);

  int get pendingCount => getAll().length;

  Future<void> _save(List<SyncAction> queue) async =>
      _storage.setJsonList(_key, queue.map((a) => a.toJson()).toList());
}
