import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../shared/widgets/flag_stripe.dart';
import '../providers/auth_provider.dart';

/// Splash — solid FRELIMO red with the logo + flag stripe. While the auth
/// provider settles its initial state we sit here; once `isInitializing` is
/// false we redirect to the role-appropriate landing.
///
/// The router redirect logic owns the citizen/member/admin branching — this
/// screen just bounces to `/home` (authed) or `/login` (not authed) and lets
/// the router do the actual role-based routing.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isInitializing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (auth.isAuthenticated) {
          final u = auth.user;
          if (u?.isAdmin == true) {
            context.go('/admin');
          } else {
            context.go('/home');
          }
        } else {
          context.go('/login');
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/frelimo-logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.flag, color: AppColors.primaryRed, size: 64),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'FRELIMO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Frente de Libertação de Moçambique',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            const FlagStripeHorizontal(width: 80, height: 4),
            const SizedBox(height: 32),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
