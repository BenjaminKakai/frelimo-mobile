import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../providers/news_providers.dart';

/// Article detail — mirrors web-client `/noticias/[slug]`. Fetched by slug
/// via `articleBySlugProvider`; a null result renders the polite empty state
/// the provider promises rather than an error.
class ArticleScreen extends ConsumerWidget {
  final String slug;
  const ArticleScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(articleBySlugProvider(slug));

    return Scaffold(
      appBar: AppBar(
        title: Text('news.title'.tr(ref)),
        actions: [
          async.maybeWhen(
            data: (a) => a == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: 'news.share'.tr(ref),
                    onPressed: () => Share.share('${a.title}\n\n${a.excerpt ?? ''}'),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('common.error'.tr(ref))),
        data: (a) {
          if (a == null) {
            return Center(child: Text('news.empty'.tr(ref)));
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (a.coverUrl != null && a.coverUrl!.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(a.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color:
                              AppColors.primaryRed.withValues(alpha: 0.08))),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (a.category != null)
                      Text(a.category!.toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primaryRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(a.title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900)),
                    if (a.publishedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(DateFormat.yMMMMd().format(a.publishedAt!),
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                    const SizedBox(height: 20),
                    Text(a.body ?? a.excerpt ?? '',
                        style: const TextStyle(fontSize: 16, height: 1.6)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
