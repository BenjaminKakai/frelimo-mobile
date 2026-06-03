import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../../shared/models/content_models.dart';
import '../providers/voting_providers.dart';

/// Elections list — mirrors web-client `/me/votar`. Groups by status into
/// Open / Upcoming / Closed sections. Tapping an election pushes the detail
/// route where the actual ballot lives.
class VotingScreen extends ConsumerWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(electionsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('voting.title'.tr(ref))),
      body: RefreshIndicator(
        onRefresh: () => ref.read(electionsListProvider.notifier).refresh(),
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
                Center(child: Text('voting.empty'.tr(ref))),
              ]);
            }
            final open =
                list.where((e) => e.status == 'OPEN').toList();
            final upcoming =
                list.where((e) => e.status == 'UPCOMING').toList();
            final closed = list
                .where((e) => e.status == 'CLOSED' || e.status == 'DRAFT')
                .toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section(context, ref, 'voting.open'.tr(ref), open,
                    AppColors.brandGreen),
                _section(context, ref, 'voting.upcoming'.tr(ref), upcoming,
                    AppColors.warning),
                _section(context, ref, 'voting.closed'.tr(ref), closed,
                    Colors.grey),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(BuildContext context, WidgetRef ref, String title,
      List<Election> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: color)),
        ),
        ...items.map((e) => Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                title: Text(e.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: e.scope != null ? Text(e.scope!) : null,
                trailing: e.hasVoted
                    ? const Icon(Icons.check_circle,
                        color: AppColors.brandGreen, size: 20)
                    : const Icon(Icons.chevron_right),
                onTap: () => context.push('/vote/${e.id}'),
              ),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}
