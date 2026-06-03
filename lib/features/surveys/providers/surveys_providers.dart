import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_unwrap.dart';
import '../../../shared/models/content_models.dart';
import '../../auth/providers/auth_provider.dart';

class SurveysListNotifier extends StateNotifier<AsyncValue<List<Survey>>> {
  final Ref _ref;
  SurveysListNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final res = await _ref.read(apiClientProvider).get('/surveys');
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

final surveyDetailProvider =
    FutureProvider.family<Survey?, String>((ref, id) async {
  try {
    final res = await ref.read(apiClientProvider).get('/surveys/$id');
    final m = ApiUnwrap.map(res.data);
    return m == null ? null : Survey.fromJson(m);
  } catch (_) {
    return null;
  }
});

Future<bool> submitSurveyResponse(
    WidgetRef ref, String surveyId, Map<String, dynamic> answers) async {
  try {
    await ref.read(apiClientProvider).post(
      '/surveys/$surveyId/responses',
      data: {'answers': answers},
    );
    return true;
  } catch (_) {
    return false;
  }
}
