import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../providers/news_providers.dart';

/// News feed — mirrors web-client `/noticias`. Infinite list with a bottom
/// loader; tapping a card pushes `/news/:slug`. We trigger `load()` once on
/// first build (the notifier starts empty, unlike the auto-loading list
/// notifiers, because the feed is paginated and we want loadMore control).
class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});
  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(newsFeedProvider).items.isEmpty) {
        ref.read(newsFeedProvider.notifier).load();
      }
    });
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 300) {
        ref.read(newsFeedProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsFeedProvider);

    return Scaffold(
      appBar: AppBar(title: Text('news.title'.tr(ref))),
      body: RefreshIndicator(
        onRefresh: () => ref.read(newsFeedProvider.notifier).refresh(),
        child: state.items.isEmpty && state.loading
            ? const Center(child: CircularProgressIndicator())
            : state.items.isEmpty
                ? ListView(children: [
                    const SizedBox(height: 100),
                    Center(child: Text('news.empty'.tr(ref))),
                  ])
                : ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      if (i >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))),
                        );
                      }
                      final a = state.items[i];
                      return _ArticleCard(
                        article: a,
                        onTap: () => context.push('/news/${a.slug}'),
                      );
                    },
                  ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final dynamic article;
  final VoidCallback onTap;
  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = article;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.coverUrl != null && a.coverUrl!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  a.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primaryRed.withValues(alpha: 0.08),
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.primaryRed),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (a.category != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        a.category!.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1),
                      ),
                    ),
                  Text(a.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  if (a.excerpt != null) ...[
                    const SizedBox(height: 6),
                    Text(a.excerpt!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color)),
                  ],
                  if (a.publishedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(DateFormat.yMMMMd().format(a.publishedAt!),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
