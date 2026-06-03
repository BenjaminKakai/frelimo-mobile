import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../auth/providers/auth_provider.dart';

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key});
  @override
  ConsumerState<AdminMembersScreen> createState() =>
      _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = const [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ref.read(apiClientProvider).get(
            '/admin/members',
            queryParameters: {
              if (_searchCtrl.text.trim().isNotEmpty) 'q': _searchCtrl.text.trim()
            },
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Pesquisar membros...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _load,
              ),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_items.isEmpty
                  ? const Center(child: Text('Sem resultados'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final m = _items[i];
                        final name = [m['firstName'], m['lastName']]
                            .where((s) => s != null && s.toString().isNotEmpty)
                            .join(' ');
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primaryRed.withValues(alpha: 0.12),
                            child: Text(
                              (name.isEmpty ? '?' : name[0]).toUpperCase(),
                              style: const TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          title: Text(name.isEmpty ? m['email'] ?? '' : name),
                          subtitle: Text(m['memberNumber']?.toString() ?? '—'),
                          trailing: Text(
                            (m['status'] ?? '').toString(),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1),
                          ),
                        );
                      },
                    )),
        ),
      ],
    );
  }
}
