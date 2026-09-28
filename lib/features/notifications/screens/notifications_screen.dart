import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../../shared/models/content_models.dart';
import '../providers/notifications_providers.dart';

/// Notifications list — mirrors web-client `/me/notificacoes`. Unread rows are
/// tinted and carry a "mark as read" action; tapping a row marks it too.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('notifications.title'.tr(ref))),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
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
                Center(child: Text('notifications.empty'.tr(ref))),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _NotificationCard(item: list[i]),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final AppNotification item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = item.unread;
    final theme = Theme.of(context);
    // Fall back to the template name so a payload with no title/body still
    // tells the member which kind of message arrived.
    final text = item.body ?? item.template;

    return Card(
      color: unread
          ? AppColors.primaryRed.withValues(alpha: 0.06)
          : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: unread
              ? AppColors.primaryRed.withValues(alpha: 0.35)
              : theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: unread
            ? () => ref.read(notificationsProvider.notifier).markRead(item.id)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.channel} · ${item.template}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                  if (unread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              if (item.title != null) ...[
                const SizedBox(height: 6),
                Text(item.title!,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
              if (text.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(text, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    item.createdAt != null
                        ? DateFormat.yMMMd().add_Hm().format(item.createdAt!)
                        : '',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7)),
                  ),
                  const Spacer(),
                  if (unread)
                    TextButton(
                      onPressed: () => ref
                          .read(notificationsProvider.notifier)
                          .markRead(item.id),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('notifications.markRead'.tr(ref),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800)),
                    )
                  else
                    Text('notifications.read'.tr(ref),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandGreen
                                .withValues(alpha: 0.9))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
