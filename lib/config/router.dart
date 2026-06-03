import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/admin/screens/admin_shell.dart';
import '../features/admin/screens/qr_scanner_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/member/screens/digital_card_screen.dart';
import '../features/member/screens/dues_screen.dart';
import '../features/member/screens/home_screen.dart';
import '../features/news/screens/article_screen.dart';
import '../features/news/screens/news_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/reports/screens/report_screen.dart';
import '../features/reports/screens/suggestion_screen.dart';
import '../features/surveys/screens/survey_detail_screen.dart';
import '../features/surveys/screens/surveys_screen.dart';
import '../features/voting/screens/election_detail_screen.dart';
import '../features/voting/screens/voting_screen.dart';

/// Role-aware redirect lives here — one source of truth for the
/// citizen / member / admin branching that the architecture decision calls
/// for. We deliberately use `ref.listen` (not `ref.watch`) on the auth
/// state so the router isn't rebuilt on every auth change — `GoRouter`
/// re-runs `redirect` via `refreshListenable` instead, which keeps the
/// current location intact.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
  AuthState get auth => _ref.read(authProvider);
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = notifier.auth;
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/splash' ||
          loc == '/login' ||
          loc == '/forgot-password';

      // Still booting — stay on splash, don't redirect.
      if (auth.isInitializing) {
        return loc == '/splash' ? null : '/splash';
      }

      if (!auth.isAuthenticated) {
        return onAuthPage ? null : '/login';
      }

      // Authenticated branch — citizen/member share /home, admin gets
      // bounced into the admin shell. If an admin somehow lands on /home
      // we redirect them up; vice versa for a citizen on /admin.
      final isAdmin = auth.user?.isAdmin == true;
      if (loc == '/login' || loc == '/splash') {
        return isAdmin ? '/admin' : '/home';
      }
      if (loc.startsWith('/admin') && !isAdmin) return '/home';
      if (loc == '/home' && isAdmin) return '/admin';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),

      // Citizen / member shell
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/card', builder: (_, __) => const DigitalCardScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/dues', builder: (_, __) => const DuesScreen()),

      // Member content & participation
      GoRoute(path: '/news', builder: (_, __) => const NewsScreen()),
      GoRoute(
          path: '/news/:slug',
          builder: (_, s) =>
              ArticleScreen(slug: s.pathParameters['slug']!)),
      GoRoute(path: '/vote', builder: (_, __) => const VotingScreen()),
      GoRoute(
          path: '/vote/:id',
          builder: (_, s) =>
              ElectionDetailScreen(electionId: s.pathParameters['id']!)),
      GoRoute(path: '/surveys', builder: (_, __) => const SurveysScreen()),
      GoRoute(
          path: '/surveys/:id',
          builder: (_, s) =>
              SurveyDetailScreen(surveyId: s.pathParameters['id']!)),
      GoRoute(path: '/report', builder: (_, __) => const ReportScreen()),
      GoRoute(path: '/suggest', builder: (_, __) => const SuggestionScreen()),

      // Admin shell
      GoRoute(path: '/admin', builder: (_, __) => const AdminShell()),
      GoRoute(
          path: '/admin/scan',
          builder: (_, __) => const QrScannerScreen()),
    ],
  );
});
