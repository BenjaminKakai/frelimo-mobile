import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_unwrap.dart';
import '../../../shared/models/content_models.dart';
import '../../auth/providers/auth_provider.dart';

/// Surveys live under the engagement module on the backend — `/surveys` is
/// not a route and returns 404. Every path here is `/engagement/surveys…`.
const _base = '/engagement/surveys';

class SurveysListNotifier extends StateNotifier<AsyncValue<List<Survey>>> {
  final Ref _ref;
  SurveysListNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final res = await _ref.read(apiClientProvider).get(_base);
      final list = ApiUnwrap.list(res.data)
          .map((e) => Survey.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load();
}

final surveysListProvider = StateNotifierProvider<SurveysListNotifier,
    AsyncValue<List<Survey>>>((ref) {
  return SurveysListNotifier(ref);
});

/// Survey detail. There is no `GET /engagement/surveys/:id` on the backend,
/// but the list route already returns whole rows — `questions` included — so
/// we pick the one we want out of the list rather than calling a route that
/// would 404.
final surveyDetailProvider =
    FutureProvider.family<Survey?, String>((ref, id) async {
  try {
    final res = await ref.read(apiClientProvider).get(_base);
    final row = ApiUnwrap.list(res.data).firstWhere(
      (e) => e['id']?.toString() == id,
      orElse: () => const <String, dynamic>{},
    );
    return row.isEmpty ? null : Survey.fromJson(row);
  } catch (_) {
    return null;
  }
});

/// Submit answers. The backend route is `…/:id/respond` (not `/responses`)
/// and takes the answer map as the body.
Future<bool> submitSurveyResponse(
    WidgetRef ref, String surveyId, Map<String, dynamic> answers) async {
  try {
    await ref.read(apiClientProvider).post(
      '$_base/$surveyId/respond',
      data: {'answers': answers},
    );
    return true;
  } catch (_) {
    return false;
  }
}
