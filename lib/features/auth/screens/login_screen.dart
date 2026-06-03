import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../../shared/widgets/flag_stripe.dart';
import '../providers/auth_provider.dart';

/// Single login form — citizens, members, and admins all enter here. The
/// post-login routing is decided by the `isAdmin` / `isMember` flags on the
/// `/profile/me` response, which the router redirect inspects.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final auth = ref.read(authProvider.notifier);
    auth.login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authProvider, (prev, next) {
      // The router redirect handles which shell to drop into based on role.
      // We just need to react to the error toast here.
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    final bg = isDark ? AppColors.darkBg : Colors.white;
    final surface =
        isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF5F5F7);
    final border =
        isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE8E8EC);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;
    final hintColor = isDark ? Colors.white24 : Colors.black26;
    final iconColor = isDark ? Colors.white38 : Colors.black38;

    InputDecoration fd(String hint, IconData icon, {Widget? suffix}) =>
        InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(icon, size: 18, color: iconColor),
          suffixIcon: suffix,
          filled: true,
          fillColor: surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primaryRed, width: 1.5)),
        );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Top bar: language toggle on the right, no left chrome
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const FlagStripeHorizontal(width: 56, height: 4),
                  TextButton(
                    onPressed: () =>
                        ref.read(localeProvider.notifier).toggle(),
                    child: Text(
                      ref.watch(localeProvider).languageCode == 'pt'
                          ? 'EN'
                          : 'PT',
                      style: TextStyle(
                        color: subColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Image.asset(
                  'assets/images/frelimo-logo.png',
                  height: 88,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.flag,
                    size: 88,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'login.welcome'.tr(ref),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'login.subtitle'.tr(ref),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: subColor),
              ),
              const SizedBox(height: 32),
              Text('login.email'.tr(ref),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: subColor)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 14, color: textColor),
                decoration: fd('email@frelimo.org.mz', Icons.mail_outline_rounded),
              ),
              const SizedBox(height: 16),
              Text('login.password'.tr(ref),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: subColor)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: TextStyle(fontSize: 14, color: textColor),
                onSubmitted: (_) => auth.isLoading ? null : _submit(),
                decoration: fd('••••••••', Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: iconColor),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.push('/forgot-password'),
                  child: Text(
                    'login.forgot'.tr(ref),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          'login.cta'.tr(ref),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3),
                        ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
