import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../../shared/widgets/flag_stripe.dart';
import '../../auth/providers/auth_provider.dart';
import '../../news/providers/news_providers.dart';

/// Citizen / member home — single screen that adapts based on the
/// `isMember` + `status` flags. We deliberately do NOT split into two
/// separate routes because the only real difference is the status banner,
/// the "apply for membership" CTA, and the digital-card tile being live.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final status = (user?.status ?? 'CITIZEN').toUpperCase();
    final isMember = user?.isMember == true;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/frelimo-logo.png',
                height: 28,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.flag, color: AppColors.primaryRed)),
            const SizedBox(width: 10),
            const Text('FRELIMO',
                style: TextStyle(
                    letterSpacing: 2, fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            child: Text(
              ref.watch(localeProvider).languageCode == 'pt' ? 'EN' : 'PT',
              style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshProfile();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WelcomeCard(name: user?.fullName ?? '', status: status),
            const SizedBox(height: 16),
            if (!isMember)
              Card(
                color: AppColors.brandGold.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                      color: AppColors.brandGold.withValues(alpha: 0.4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home.applyMembership'.tr(ref),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            _comingSoon(context, 'Apply for Membership'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                        ),
                        child: Text('common.continue'.tr(ref)),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const FlagStripeHorizontal(width: 48, height: 3),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _Tile(
                  icon: Icons.badge_outlined,
                  label: 'home.tile.card'.tr(ref),
                  onTap: () => isMember
                      ? context.push('/card')
                      : _comingSoon(context, 'Members only'),
                ),
                _Tile(
                    icon: Icons.payments_outlined,
                    label: 'home.tile.dues'.tr(ref),
                    onTap: () => context.push('/dues')),
                _Tile(
                    icon: Icons.how_to_vote_outlined,
                    label: 'home.tile.vote'.tr(ref),
                    onTap: () => context.push('/vote')),
                _Tile(
                    icon: Icons.poll_outlined,
                    label: 'home.tile.surveys'.tr(ref),
                    onTap: () => context.push('/surveys')),
                _Tile(
                    icon: Icons.report_outlined,
                    label: 'home.tile.report'.tr(ref),
                    onTap: () => context.push('/report')),
                _Tile(
                    icon: Icons.lightbulb_outline,
                    label: 'home.tile.suggest'.tr(ref),
                    onTap: () => context.push('/suggest')),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('home.recentNews'.tr(ref),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                TextButton(
                  onPressed: () => context.push('/news'),
                  child: Text('news.read'.tr(ref),
                      style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const _RecentNews(),
            // bottom space for the profile icon
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/profile'),
        child: const Icon(Icons.person_outline),
      ),
    );
  }

  void _comingSoon(BuildContext c, String label) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(
      content: Text('$label — em breve'),
      backgroundColor: AppColors.darkSurface,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

class _WelcomeCard extends ConsumerWidget {
  final String name;
  final String status;
  const _WelcomeCard({required this.name, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (chipColor, chipLabel) = switch (status) {
      'VERIFIED' => (AppColors.brandGreen, 'home.status.verified'.tr(ref)),
      'PENDING' => (AppColors.warning, 'home.status.pending'.tr(ref)),
      'SUSPENDED' => (AppColors.primaryRed, 'home.status.suspended'.tr(ref)),
      _ => (Colors.grey.shade600, 'home.status.citizen'.tr(ref)),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryRed,
            AppColors.primaryRed.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const FlagStripe(width: 8, height: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('home.welcome'.tr(ref),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    chipLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.primaryRed),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Top-3 recent articles on the home feed. Triggers a one-time load of the
/// shared `newsFeedProvider` (the full /news screen reuses the same state),
/// shows a compact list, and falls back to a "no news yet" line.
class _RecentNews extends ConsumerStatefulWidget {
  const _RecentNews();
  @override
  ConsumerState<_RecentNews> createState() => _RecentNewsState();
}

class _RecentNewsState extends ConsumerState<_RecentNews> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(newsFeedProvider).items.isEmpty) {
        ref.read(newsFeedProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsFeedProvider);
    if (state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            state.loading ? 'common.loading'.tr(ref) : 'news.empty'.tr(ref),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    final top = state.items.take(3).toList();
    return Column(
      children: top
          .map((a) => Card(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (a.coverUrl != null && a.coverUrl!.isNotEmpty)
                        ? Image.network(a.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.article_outlined,
                                color: AppColors.primaryRed))
                        : const Icon(Icons.article_outlined,
                            color: AppColors.primaryRed),
                  ),
                  title: Text(a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: a.category != null ? Text(a.category!) : null,
                  onTap: () => context.push('/news/${a.slug}'),
                ),
              ))
          .toList(),
    );
  }
}
