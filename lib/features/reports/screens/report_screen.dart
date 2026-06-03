import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../providers/reports_providers.dart';

/// Citizen issue report — mirrors web-client `/me/reportar`. POSTs to
/// `/issues` via `submitIssue`. On success we pop back to the previous screen
/// with a confirmation snackbar (the web flow shows an inline thank-you;
/// mobile favours dismissing the form so the member returns to home).
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  String _category = 'infra';
  bool _submitting = false;

  static const _categories = {
    'infra': 'report.cat.infra',
    'services': 'report.cat.services',
    'security': 'report.cat.security',
    'health': 'report.cat.health',
    'other': 'report.cat.other',
  };

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await submitIssue(ref, {
      'subject': _subject.text.trim(),
      'description': _description.text.trim(),
      'category': _category.toUpperCase(),
      if (_location.text.trim().isNotEmpty) 'location': _location.text.trim(),
    });
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'report.success'.tr(ref) : 'common.error'.tr(ref)),
      backgroundColor: ok ? AppColors.brandGreen : AppColors.primaryRed,
      behavior: SnackBarBehavior.floating,
    ));
    if (ok) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('report.title'.tr(ref))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _subject,
              decoration: InputDecoration(
                  labelText: 'report.subject'.tr(ref),
                  border: const OutlineInputBorder()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '—' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                  labelText: 'report.category'.tr(ref),
                  border: const OutlineInputBorder()),
              items: _categories.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key, child: Text(e.value.tr(ref))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'infra'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLines: 5,
              decoration: InputDecoration(
                  labelText: 'report.description'.tr(ref),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '—' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              decoration: InputDecoration(
                  labelText: 'report.location'.tr(ref),
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('report.submit'.tr(ref)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
