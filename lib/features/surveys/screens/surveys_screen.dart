import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../providers/surveys_providers.dart';

/// Surveys list — mirrors web-client `/me/sondagens`. Each row shows an
/// answered/to-answer chip; tapping pushes the questionnaire at
/// `/surveys/:id`.
class SurveysScreen extends ConsumerWidget {
  const SurveysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(surveysListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('surveys.title'.tr(ref))),
      body: RefreshIndicator(
        onRefresh: () => ref.read(surveysListProvider.notifier).refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ListView(children: [
            const SizedBox(height: 100),
            Center(child: Text('common.error'.tr(ref))),
          ]),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: [
                const SizedBox(height: 100),
                Center(child: Text('surveys.empty'.tr(ref))),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final s = list[i];
                final (color, label) = s.answered
                    ? (AppColors.brandGreen, 'surveys.answered'.tr(ref))
                    : (AppColors.warning, 'surveys.toAnswer'.tr(ref));
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    title: Text(s.title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle:
                        s.description != null ? Text(s.description!) : null,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Text(label,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11)),
                    ),
                    onTap: () => context.push('/surveys/${s.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
