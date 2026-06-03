import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../auth/providers/auth_provider.dart';

/// Verification queue. Each card shows a pending application with quick
/// approve / suspend buttons. The actual decision endpoint is
/// /admin/members/:id/verify with `{ action: APPROVE | SUSPEND, reason? }`.
class AdminVerificationScreen extends ConsumerStatefulWidget {
  const AdminVerificationScreen({super.key});
  @override
  ConsumerState<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState
    extends ConsumerState<AdminVerificationScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ref.read(apiClientProvider).get(
        '/admin/members',
        queryParameters: {'status': 'PENDING'},
      );
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      final list = data is List ? data : (data is Map ? data['items'] : []);
      _items = (list as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      _items = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _act(String id, String action) async {
    try {
      await ref.read(apiClientProvider).post(
        '/admin/members/$id/verify',
        data: {'action': action},
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('common.error'.tr(ref)),
        backgroundColor: AppColors.primaryRed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return Center(child: Text('common.comingSoon'.tr(ref)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final m = _items[i];
          final name = [m['firstName'], m['lastName']]
              .where((s) => s != null && s.toString().isNotEmpty)
              .join(' ');
          final id = m['id']?.toString() ?? '';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isEmpty ? (m['email'] ?? '') : name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(m['email']?.toString() ?? '',
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    [
                      m['province'],
                      m['district'],
                      m['ward'],
                      m['cell']
                    ]
                        .where((s) => s != null && s.toString().isNotEmpty)
                        .join(' · '),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _act(id, 'APPROVE'),
                          icon: const Icon(Icons.check),
                          label: Text('admin.approve'.tr(ref)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandGreen),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _act(id, 'SUSPEND'),
                          icon: const Icon(Icons.block),
                          label: Text('admin.suspend'.tr(ref)),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryRed),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
