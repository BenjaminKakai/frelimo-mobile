import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_unwrap.dart';
import '../../../shared/models/content_models.dart';
import '../../auth/providers/auth_provider.dart';

/// News feed — paginated, optionally filtered by category. Screens call
/// `load()` once and `loadMore()` on bottom-reach; `refresh()` resets to
/// page 1.
class NewsFeedState {
  final List<Article> items;
  final String? category;
  final int page;
  final bool hasMore;
  final bool loading;
  final String? error;
  const NewsFeedState({
    this.items = const [],
    this.category,
    this.page = 1,
    this.hasMore = true,
    this.loading = false,
    this.error,
  });
  NewsFeedState copyWith({
    List<Article>? items,
    String? category,
    int? page,
    bool? hasMore,
    bool? loading,
    String? error,
    bool clearError = false,
    bool clearCategory = false,
  }) =>
      NewsFeedState(
        items: items ?? this.items,
        category: clearCategory ? null : (category ?? this.category),
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
}

class NewsFeedNotifier extends StateNotifier<NewsFeedState> {
  final Ref _ref;
  static const _pageSize = 20;
  NewsFeedNotifier(this._ref) : super(const NewsFeedState());

  Future<void> load() async {
    if (state.loading) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final res = await _ref.read(apiClientProvider).get(
        '/news/feed',
        queryParameters: {
          'page': 1,
          'pageSize': _pageSize,
          if (state.category != null) 'category': state.category,
        },
      );
      final list = ApiUnwrap.list(res.data)
          .map((e) => Article.fromJson(e))
          .toList();
      state = state.copyWith(
        items: list,
        page: 1,
        hasMore: list.length >= _pageSize,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    final next = state.page + 1;
    state = state.copyWith(loading: true);
    try {
      final res = await _ref.read(apiClientProvider).get(
        '/news/feed',
        queryParameters: {
          'page': next,
          'pageSize': _pageSize,
          if (state.category != null) 'category': state.category,
        },
      );
      final more = ApiUnwrap.list(res.data)
          .map((e) => Article.fromJson(e))
          .toList();
      state = state.copyWith(
        items: [...state.items, ...more],
        page: next,
        hasMore: more.length >= _pageSize,
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> setCategory(String? c) async {
    state = state.copyWith(
        category: c,
        clearCategory: c == null,
        items: const [],
        page: 1,
        hasMore: true);
    await load();
  }
}

final newsFeedProvider =
    StateNotifierProvider<NewsFeedNotifier, NewsFeedState>((ref) {
  return NewsFeedNotifier(ref);
});

/// Article detail — fetched by slug. Returns null if the slug is unknown so
/// the screen can show a polite empty state.
final articleBySlugProvider =
    FutureProvider.family<Article?, String>((ref, slug) async {
  try {
    final res = await ref.read(apiClientProvider).get('/news/article/$slug');
    final m = ApiUnwrap.map(res.data);
    return m == null ? null : Article.fromJson(m);
  } catch (_) {
    return null;
  }
});
