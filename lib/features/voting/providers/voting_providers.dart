import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_unwrap.dart';
import '../../../shared/models/content_models.dart';
import '../../auth/providers/auth_provider.dart';

/// All elections (open/upcoming/closed). The list screen groups by status;
/// `refresh()` re-pulls the full list.
class ElectionsListNotifier
    extends StateNotifier<AsyncValue<List<Election>>> {
  final Ref _ref;
  ElectionsListNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final res = await _ref.read(apiClientProvider).get('/elections');
      final list = ApiUnwrap.list(res.data)
          .map((e) => Election.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load();
}

final electionsListProvider = StateNotifierProvider<ElectionsListNotifier,
    AsyncValue<List<Election>>>((ref) {
  return ElectionsListNotifier(ref);
});

final electionDetailProvider =
    FutureProvider.family<Election?, String>((ref, id) async {
  try {
    final res = await ref.read(apiClientProvider).get('/elections/$id');
    final m = ApiUnwrap.map(res.data);
    return m == null ? null : Election.fromJson(m);
  } catch (_) {
    return null;
  }
});

/// Cast a vote. Returns a string status: 'OK', 'ALREADY_VOTED', or 'ERROR'.
/// 'ALREADY_VOTED' covers the backend's idempotency response (400 with
/// "Already voted" message) so the screen can show a friendly state instead
/// of a red error.
Future<String> castVote(
    WidgetRef ref, String electionId, String candidateId) async {
  try {
    await ref.read(apiClientProvider).post(
      '/elections/$electionId/vote',
      data: {'candidateId': candidateId},
    );
    return 'OK';
  } on DioException catch (e) {
    final msg = (e.response?.data is Map
            ? (e.response?.data['error']?['message'] ??
                e.response?.data['message'])
            : null)
        ?.toString()
        .toLowerCase();
    if (e.response?.statusCode == 400 &&
        msg != null &&
        (msg.contains('already') || msg.contains('voted') || msg.contains('já'))) {
      return 'ALREADY_VOTED';
    }
    return 'ERROR';
  } catch (_) {
    return 'ERROR';
  }
}
