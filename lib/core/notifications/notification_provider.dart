import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationState {
  final int    unreadCount;
  final List<RemoteMessage> recent;

  const NotificationState({
    this.unreadCount = 0,
    this.recent      = const [],
  });

  NotificationState copyWith({
    int?                   unreadCount,
    List<RemoteMessage>?   recent,
  }) => NotificationState(
    unreadCount: unreadCount ?? this.unreadCount,
    recent:      recent      ?? this.recent,
  );
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    _listen();
  }

  void _listen() {
    FirebaseMessaging.onMessage.listen((message) {
      state = state.copyWith(
        unreadCount: state.unreadCount + 1,
        recent:      [message, ...state.recent].take(20).toList(),
      );
    });
  }

  void markAllRead() => state = state.copyWith(unreadCount: 0);
}
