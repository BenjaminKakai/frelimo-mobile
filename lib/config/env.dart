/// Build-time environment override.
///
/// To point the app at a different backend (e.g. localhost during demo),
/// pass `--dart-define=FRELIMO_API_URL=https://...`.
///
/// Default is the FRELIMO production-staging gateway hosted on Wasaa.
class Env {
  static const String apiUrl = String.fromEnvironment(
    'FRELIMO_API_URL',
    defaultValue: 'https://api-frelimo.wasaahost.com/api/v1',
  );

  /// The tenant slug the backend uses to scope every request. Sent on every
  /// API call as `X-Tenant: frelimo`. Override per build flavour if a future
  /// white-label fork ships under a different tenant code.
  static const String tenant = String.fromEnvironment(
    'FRELIMO_TENANT',
    defaultValue: 'frelimo',
  );

  /// Public verification URL embedded in the digital card QR. A branch
  /// scanner (or anyone with a phone) hitting this URL sees the public
  /// member card (no PII).
  static const String verifyBaseUrl = String.fromEnvironment(
    'FRELIMO_VERIFY_URL',
    defaultValue: 'https://frelimo.wasaahost.com/verify',
  );

  static const String appName = 'FRELIMO';

  static const String accessTokenKey  = 'frelimo_access_token';
  static const String refreshTokenKey = 'frelimo_refresh_token';
  static const String userKey         = 'frelimo_user';
  static const String profileKey      = 'frelimo_profile_cache';
  static const String localeKey       = 'frelimo_locale';
  static const String themeKey        = 'frelimo_theme';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
