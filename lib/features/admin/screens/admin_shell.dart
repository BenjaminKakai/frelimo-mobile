import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../auth/providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_members_screen.dart';
import 'admin_verification_screen.dart';

/// Admin / politician bottom-nav shell. The user lands here only when
/// `/profile/me` returns `isAdmin: true` — see the redirect logic in the
/// router. Sector heads, verification staff, and politicians all share the
/// same UI; the backend gates what each role can actually mutate.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});
  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AdminDashboardScreen(),
      AdminMembersScreen(),
      AdminVerificationScreen(),
      _ComingSoonTab(label: 'admin.news'),
      _MoreTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/frelimo-logo.png',
                height: 24,
                errorBuilder: (_, __, ___) => const Icon(Icons.flag)),
            const SizedBox(width: 8),
            const Text('FRELIMO Admin',
                style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'admin.scanQr'.tr(ref),
            onPressed: () => context.push('/admin/scan'),
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
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard,
                  color: AppColors.primaryRed),
              label: 'admin.dashboard'.tr(ref)),
          NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon:
                  const Icon(Icons.people, color: AppColors.primaryRed),
              label: 'admin.members'.tr(ref)),
          NavigationDestination(
              icon: const Icon(Icons.verified_user_outlined),
              selectedIcon: const Icon(Icons.verified_user,
                  color: AppColors.primaryRed),
              label: 'admin.verification'.tr(ref)),
          NavigationDestination(
              icon: const Icon(Icons.article_outlined),
              selectedIcon:
                  const Icon(Icons.article, color: AppColors.primaryRed),
              label: 'admin.news'.tr(ref)),
          NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              selectedIcon:
                  const Icon(Icons.more_horiz, color: AppColors.primaryRed),
              label: 'admin.more'.tr(ref)),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends ConsumerWidget {
  final String label;
  const _ComingSoonTab({required this.label});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
        child: Text(
          '${label.tr(ref)} — ${'common.comingSoon'.tr(ref)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
}

class _MoreTab extends ConsumerWidget {
  const _MoreTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(
              ref.watch(localeProvider).languageCode == 'pt' ? 'English' : 'Português'),
          onTap: () => ref.read(localeProvider.notifier).toggle(),
        ),
        ListTile(
          leading: const Icon(Icons.qr_code_scanner),
          title: Text('admin.scanQr'.tr(ref)),
          onTap: () => context.push('/admin/scan'),
        ),
      ],
    );
  }
}
