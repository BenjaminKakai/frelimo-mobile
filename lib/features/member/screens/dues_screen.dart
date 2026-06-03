import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../auth/providers/auth_provider.dart';

/// Quotas (member dues). Lists periods with PAID/DUE/OVERDUE chips and a
/// "Pagar agora" sheet that POSTs to /finance/quotas/:id/pay with
/// `paidVia: 'MPESA'`. We don't currently wait for the M-Pesa STK callback
/// to come back inline — the backend pushes the success state via the
/// notification channel.
class DuesScreen extends ConsumerStatefulWidget {
  const DuesScreen({super.key});
  @override
  ConsumerState<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends ConsumerState<DuesScreen> {
  bool _loading = true;
  List<_Dues> _items = const [];
  String? _err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final res = await ref.read(apiClientProvider).get('/finance/quotas');
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      final list = data is List ? data : (data is Map ? data['items'] : []);
      _items = (list as List)
          .map((e) => _Dues.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _err = 'common.error';
      _items = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _payNow(_Dues d) async {
    final phoneCtrl = TextEditingController();
    final amountCtrl =
        TextEditingController(text: d.amount.toStringAsFixed(0));

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('common.payNow'.tr(ref),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: 'dues.phone'.tr(ref),
                  hintText: '+258...'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'dues.amount'.tr(ref)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(sheetCtx).pop(true),
              child: Text('common.payNow'.tr(ref)),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(apiClientProvider).post(
        '/finance/quotas/${d.id}/pay',
        data: {
          'phone': phoneCtrl.text.trim(),
          'amount': double.tryParse(amountCtrl.text.trim()) ?? d.amount,
          'paidVia': 'MPESA',
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('STK Push enviado'),
        backgroundColor: AppColors.brandGreen,
        behavior: SnackBarBehavior.floating,
      ));
      _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('common.error'.tr(ref)),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('dues.title'.tr(ref))),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_items.isEmpty
                ? ListView(children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(_err == null
                          ? 'common.comingSoon'.tr(ref)
                          : 'common.error'.tr(ref)),
                    ),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final d = _items[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          title: Text(d.period,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800)),
                          subtitle: Text(d.paidAt != null
                              ? DateFormat.yMMMd().format(d.paidAt!)
                              : NumberFormat.currency(symbol: 'MZN ')
                                  .format(d.amount)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StatusChip(status: d.status),
                              if (d.status != 'PAID')
                                IconButton(
                                  icon: const Icon(Icons.payment),
                                  color: AppColors.primaryRed,
                                  onPressed: () => _payNow(d),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
      ),
    );
  }
}

class _StatusChip extends ConsumerWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (color, label) = switch (status) {
      'PAID' => (AppColors.brandGreen, 'dues.paid'.tr(ref)),
      'OVERDUE' => (AppColors.primaryRed, 'dues.overdue'.tr(ref)),
      _ => (AppColors.warning, 'dues.due'.tr(ref)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.5)),
    );
  }
}

class _Dues {
  final String id;
  final String period;
  final double amount;
  final String status;
  final DateTime? paidAt;
  _Dues({
    required this.id,
    required this.period,
    required this.amount,
    required this.status,
    this.paidAt,
  });
  factory _Dues.fromJson(Map<String, dynamic> j) => _Dues(
        id: j['id']?.toString() ?? '',
        period: j['period']?.toString() ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        status: j['status']?.toString() ?? 'DUE',
        paidAt:
            j['paidAt'] != null ? DateTime.tryParse(j['paidAt'].toString()) : null,
      );
}
