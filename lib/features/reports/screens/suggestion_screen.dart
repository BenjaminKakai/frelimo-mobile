import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../providers/reports_providers.dart';

/// Member suggestion — mirrors web-client `/me/sugestao`. POSTs to
/// `/feedback` via `submitSuggestion`. Same submit-and-pop pattern as the
/// report screen.
class SuggestionScreen extends ConsumerStatefulWidget {
  const SuggestionScreen({super.key});
  @override
  ConsumerState<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends ConsumerState<SuggestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  String _category = 'general';
  bool _submitting = false;

  static const _categories = {
    'general': 'suggest.cat.general',
    'programme': 'suggest.cat.programme',
    'comms': 'suggest.cat.comms',
    'other': 'suggest.cat.other',
  };

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await submitSuggestion(ref, {
      'subject': _subject.text.trim(),
      'message': _message.text.trim(),
      'category': _category.toUpperCase(),
    });
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'suggest.success'.tr(ref) : 'common.error'.tr(ref)),
      backgroundColor: ok ? AppColors.brandGreen : AppColors.primaryRed,
      behavior: SnackBarBehavior.floating,
    ));
    if (ok) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('suggest.title'.tr(ref))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _subject,
              decoration: InputDecoration(
                  labelText: 'suggest.subject'.tr(ref),
                  border: const OutlineInputBorder()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '—' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                  labelText: 'suggest.category'.tr(ref),
                  border: const OutlineInputBorder()),
              items: _categories.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key, child: Text(e.value.tr(ref))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'general'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _message,
              maxLines: 6,
              decoration: InputDecoration(
                  labelText: 'suggest.message'.tr(ref),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '—' : null,
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
                    : Text('suggest.submit'.tr(ref)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
