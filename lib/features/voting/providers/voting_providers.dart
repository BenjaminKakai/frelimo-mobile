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

/// Election detail incl. the ballot options.
///
/// The backend exposes no `GET /elections/:id` (it 404s), so the detail is
/// composed from the two routes that do exist: the list gives us the title,
/// status and dates, and the candidates sub-resource gives us the ballot
/// options with their live counts.
final electionDetailProvider =
    FutureProvider.family<Election?, String>((ref, id) async {
  try {
    final api = ref.read(apiClientProvider);
    final responses = await Future.wait([
      api.get('/elections'),
      api.get('/elections/$id/candidates'),
    ]);

    final row = ApiUnwrap.list(responses[0].data).firstWhere(
      (e) => e['id']?.toString() == id,
      orElse: () => const <String, dynamic>{},
    );
    if (row.isEmpty) return null;

    // `_count.ballots` is how the candidates route reports the tally; flatten
    // it to the `votes` key the model reads.
    final candidates = ApiUnwrap.list(responses[1].data).map((c) {
      final count = c['_count'];
      return {
        ...c,
        'votes': c['votes'] ??
            (count is Map ? count['ballots'] : null) ??
            0,
      };
    }).toList();

    return Election.fromJson({...row, 'candidates': candidates});
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
