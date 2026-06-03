import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../providers/voting_providers.dart';

/// Election detail / ballot — mirrors web-client `/me/votar/[id]`. Lists
/// candidates with radio selection; the Vote button is only enabled when the
/// election is OPEN and the member hasn't already voted. On a successful
/// cast we invalidate both the detail and the list so the "voted" state
/// reflects everywhere without a manual refresh.
class ElectionDetailScreen extends ConsumerStatefulWidget {
  final String electionId;
  const ElectionDetailScreen({super.key, required this.electionId});
  @override
  ConsumerState<ElectionDetailScreen> createState() =>
      _ElectionDetailScreenState();
}

class _ElectionDetailScreenState
    extends ConsumerState<ElectionDetailScreen> {
  String? _selected;
  bool _submitting = false;

  Future<void> _confirmAndVote() async {
    if (_selected == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('voting.confirmTitle'.tr(ref)),
        content: Text('voting.confirmBody'.tr(ref)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text('common.cancel'.tr(ref))),
          ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text('voting.vote'.tr(ref))),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _submitting = true);
    final result = await castVote(ref, widget.electionId, _selected!);
    if (!mounted) return;
    setState(() => _submitting = false);

    final (msg, color) = switch (result) {
      'OK' => ('surveys.submitted'.tr(ref), AppColors.brandGreen),
      'ALREADY_VOTED' => ('voting.voted'.tr(ref), AppColors.warning),
      _ => ('common.error'.tr(ref), AppColors.primaryRed),
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
    if (result == 'OK' || result == 'ALREADY_VOTED') {
      ref.invalidate(electionDetailProvider(widget.electionId));
      ref.read(electionsListProvider.notifier).refresh();
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(electionDetailProvider(widget.electionId));

    return Scaffold(
      appBar: AppBar(title: Text('voting.title'.tr(ref))),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('common.error'.tr(ref))),
        data: (e) {
          if (e == null) {
            return Center(child: Text('voting.empty'.tr(ref)));
          }
          final canVote = e.status == 'OPEN' && !e.hasVoted;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(e.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    if (e.description != null) ...[
                      const SizedBox(height: 8),
                      Text(e.description!,
                          style: const TextStyle(fontSize: 15, height: 1.5)),
                    ],
                    if (e.hasVoted)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _Banner(
                            text: 'voting.voted'.tr(ref),
                            color: AppColors.brandGreen,
                            icon: Icons.check_circle),
                      )
                    else if (e.status != 'OPEN')
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _Banner(
                            text: 'voting.notOpen'.tr(ref),
                            color: AppColors.warning,
                            icon: Icons.info_outline),
                      ),
                    const SizedBox(height: 20),
                    Text('voting.candidates'.tr(ref),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.primaryRed)),
                    const SizedBox(height: 10),
                    ...e.candidates.map((c) => Card(
                          child: RadioListTile<String>(
                            value: c.id,
                            groupValue: _selected,
                            activeColor: AppColors.primaryRed,
                            onChanged: canVote
                                ? (v) => setState(() => _selected = v)
                                : null,
                            title: Text(c.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            subtitle: c.statement != null
                                ? Text(c.statement!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)
                                : null,
                          ),
                        )),
                  ],
                ),
              ),
              if (canVote)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selected == null || _submitting)
                            ? null
                            : _confirmAndVote,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16)),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('voting.vote'.tr(ref)),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _Banner(
      {required this.text, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style:
                    TextStyle(color: color, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
