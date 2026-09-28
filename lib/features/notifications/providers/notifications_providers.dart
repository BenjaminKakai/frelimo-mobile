import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_unwrap.dart';
import '../../../shared/models/content_models.dart';
import '../../auth/providers/auth_provider.dart';

/// In-app notifications for the signed-in user — mirrors web-client
/// `/me/notificacoes`. Backed by `GET /communication/notifications/me`, which
/// returns a bare array scoped to the caller.
class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final Ref _ref;
  NotificationsNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final res = await _ref
          .read(apiClientProvider)
          .get('/communication/notifications/me');
      final list = ApiUnwrap.list(res.data)
          .map((e) => AppNotification.fromJson(e))
          .toList()
        // Newest first — the backend orders by createdAt desc, but sorting
        // here keeps the screen stable if that ever changes.
        ..sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load();

  /// Mark one as read. The row is flipped locally first so the chip updates
  /// immediately; a failed call rolls back by reloading from the server.
  Future<void> markRead(String id) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final n in current)
        if (n.id == id)
          AppNotification(
            id: n.id,
            channel: n.channel,
            template: n.template,
            payload: n.payload,
            status: 'READ',
            createdAt: n.createdAt,
            readAt: DateTime.now(),
          )
        else
          n,
    ]);
    try {
      await _ref
          .read(apiClientProvider)
          .put('/communication/notifications/$id/read');
    } catch (_) {
      await load();
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<AppNotification>>>((ref) {
  return NotificationsNotifier(ref);
});

/// Unread count for the home-screen badge. Returns 0 while loading or on
/// error so the badge simply doesn't render rather than showing a spinner.
final unreadNotificationsProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).maybeWhen(
        data: (list) => list.where((n) => n.unread).length,
        orElse: () => 0,
      );
});
