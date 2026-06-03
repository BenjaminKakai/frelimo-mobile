import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'core/services/push_notification_service.dart';

/// On iOS, `Firebase.initializeApp()` crashes the app at launch when
/// `GoogleService-Info.plist` is missing — and the crash happens in
/// native ObjC code, where the surrounding Dart try/catch never fires.
/// Apple rejects this as 2.1.0 App Completeness. So we check the plist is
/// bundled before touching Firebase. When ops drops the plist in later,
/// push notifications turn on with no other code change.
Future<bool> _firebaseConfigPresent() async {
  try {
    if (Platform.isIOS) {
      await rootBundle.load('GoogleService-Info.plist');
      return true;
    }
    if (Platform.isAndroid) {
      // android/app/google-services.json is consumed by the Gradle plugin
      // at build time — if the plugin isn't applied, FirebaseApp won't
      // initialise. We try and swallow on failure below.
      return true;
    }
  } catch (_) {}
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await _firebaseConfigPresent()) {
    try {
      await Firebase.initializeApp();
      await PushNotificationService.initialize();
    } catch (_) { /* never block boot on push */ }
  }
  runApp(const ProviderScope(child: FrelimoApp()));
}

class FrelimoApp extends ConsumerWidget {
  const FrelimoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'FRELIMO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
