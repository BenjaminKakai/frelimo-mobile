import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../../shared/models/content_models.dart';
import '../providers/surveys_providers.dart';

/// Survey questionnaire — mirrors web-client `/me/sondagens` detail. Renders
/// one widget per question type (TEXT / MULTIPLE_CHOICE / SCALE / BOOLEAN);
/// answers are collected into a `{questionId: value}` map and POSTed via
/// `submitSurveyResponse`. Unsupported types render a clear placeholder
/// rather than silently dropping the question.
class SurveyDetailScreen extends ConsumerStatefulWidget {
  final String surveyId;
  const SurveyDetailScreen({super.key, required this.surveyId});
  @override
  ConsumerState<SurveyDetailScreen> createState() =>
      _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends ConsumerState<SurveyDetailScreen> {
  final Map<String, dynamic> _answers = {};
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final ok = await submitSurveyResponse(ref, widget.surveyId, _answers);
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'surveys.submitted'.tr(ref)
          : 'common.error'.tr(ref)),
      backgroundColor: ok ? AppColors.brandGreen : AppColors.primaryRed,
      behavior: SnackBarBehavior.floating,
    ));
    if (ok) {
      ref.invalidate(surveyDetailProvider(widget.surveyId));
      ref.read(surveysListProvider.notifier).refresh();
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(surveyDetailProvider(widget.surveyId));

    return Scaffold(
      appBar: AppBar(title: Text('surveys.title'.tr(ref))),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('common.error'.tr(ref))),
        data: (s) {
          if (s == null) {
            return Center(child: Text('surveys.empty'.tr(ref)));
          }
          final answered = s.answered;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(s.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    if (s.description != null) ...[
                      const SizedBox(height: 8),
                      Text(s.description!,
                          style: const TextStyle(fontSize: 15, height: 1.5)),
                    ],
                    const SizedBox(height: 20),
                    ...s.questions.map((q) => _QuestionCard(
                          question: q,
                          enabled: !answered,
                          value: _answers[q.id],
                          onChanged: (v) =>
                              setState(() => _answers[q.id] = v),
                        )),
                  ],
                ),
              ),
              if (!answered)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
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
                            : Text('surveys.submit'.tr(ref)),
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

class _QuestionCard extends ConsumerWidget {
  final SurveyQuestion question;
  final bool enabled;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  const _QuestionCard({
    required this.question,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = question;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.prompt,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _input(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _input(BuildContext context, WidgetRef ref) {
    final q = question;
    switch (q.type.toUpperCase()) {
      case 'TEXT':
        return TextField(
          enabled: enabled,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: onChanged,
        );
      case 'MULTIPLE_CHOICE':
        return Column(
          children: q.options
              .map((o) => RadioListTile<String>(
                    value: o,
                    groupValue: value as String?,
                    activeColor: AppColors.primaryRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: enabled ? (v) => onChanged(v) : null,
                    title: Text(o),
                  ))
              .toList(),
        );
      case 'BOOLEAN':
        return Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                value: true,
                groupValue: value as bool?,
                activeColor: AppColors.primaryRed,
                contentPadding: EdgeInsets.zero,
                onChanged: enabled ? (v) => onChanged(v) : null,
                title: Text('surveys.yes'.tr(ref)),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                value: false,
                groupValue: value as bool?,
                activeColor: AppColors.primaryRed,
                contentPadding: EdgeInsets.zero,
                onChanged: enabled ? (v) => onChanged(v) : null,
                title: Text('surveys.no'.tr(ref)),
              ),
            ),
          ],
        );
      case 'SCALE':
        final min = q.min ?? 1;
        final max = q.max ?? 5;
        final current = (value as num?)?.toDouble() ?? min.toDouble();
        return Column(
          children: [
            Slider(
              value: current.clamp(min.toDouble(), max.toDouble()),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min) <= 0 ? 1 : (max - min),
              label: current.round().toString(),
              activeColor: AppColors.primaryRed,
              onChanged: enabled ? (v) => onChanged(v.round()) : null,
            ),
            Text('${current.round()} / $max',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        );
      default:
        return Text('surveys.unknownType'.tr(ref),
            style: const TextStyle(color: Colors.grey));
    }
  }
}
