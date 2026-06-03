import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

/// Citizen issue report. Returns true on success — the screen handles the
/// "thank you" state.
Future<bool> submitIssue(WidgetRef ref, Map<String, dynamic> data) async {
  try {
    await ref.read(apiClientProvider).post('/issues', data: data);
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> submitSuggestion(WidgetRef ref, Map<String, dynamic> data) async {
  try {
    await ref.read(apiClientProvider).post('/feedback', data: data);
    return true;
  } catch (_) {
    return false;
  }
}
