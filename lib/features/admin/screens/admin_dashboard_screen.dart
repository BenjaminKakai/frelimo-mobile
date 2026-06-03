import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Top-level admin landing. Pulls broad totals from /admin/stats — falls
/// back gracefully if that endpoint hasn't shipped yet by surfacing the
/// loading-state placeholders rather than crashing the screen.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ref.read(apiClientProvider).get('/admin/stats');
      final data = (res.data as Map<String, dynamic>)['data'];
      if (data is Map<String, dynamic>) _stats = data;
    } catch (_) { /* leave nulls — placeholder UI handles it */ }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statCard('Membros', _stats?['totalMembers']?.toString() ?? '—',
              Icons.people_outline, AppColors.primaryRed),
          _statCard(
              'Verificações Pendentes',
              _stats?['pendingVerifications']?.toString() ?? '—',
              Icons.pending_actions_outlined,
              AppColors.warning),
          _statCard('Quotas em Atraso', _stats?['overdueDues']?.toString() ?? '—',
              Icons.payments_outlined, AppColors.brandGold),
          if (_loading) const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        subtitle: Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
