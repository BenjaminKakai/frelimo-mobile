import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/env.dart';
import '../storage/secure_storage.dart';

/// Single Dio instance used across the whole app.
///
/// Three behaviours worth knowing:
///   1. Every request carries `X-Tenant: frelimo` so the backend can scope
///      data without us having to thread the tenant slug through every URL.
///   2. The JWT comes from secure storage — never from any other source. If
///      it's missing the request still fires (so /auth/login etc. work).
///   3. On a 401 from a non-`/auth/` endpoint, we attempt one silent
///      refresh against `/auth/refresh`. If that fails, we wipe the session
///      and call `onSessionExpired` so the router can bounce to /login.
class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;
  void Function()? onSessionExpired;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Tenant': Env.tenant,
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('API: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('API ok ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint('API err ${error.response?.statusCode} ${error.requestOptions.uri}');

        // Transparent retry for transient errors on idempotent verbs. Keeps
        // the demo resilient on flaky Maputo mobile networks — without this
        // every Cloudflare hiccup would show a red error toast.
        final transient = error.type == DioExceptionType.connectionTimeout
            || error.type == DioExceptionType.receiveTimeout
            || error.type == DioExceptionType.connectionError
            || (error.response?.statusCode != null
                && error.response!.statusCode! >= 500);
        final method = error.requestOptions.method.toUpperCase();
        final isIdempotent = method == 'GET' || method == 'HEAD';
        final alreadyRetried = error.requestOptions.extra['_retried'] == true;
        if (transient && isIdempotent && !alreadyRetried) {
          try {
            await Future.delayed(const Duration(milliseconds: 400));
            error.requestOptions.extra['_retried'] = true;
            final retried = await _dio.fetch(error.requestOptions);
            return handler.resolve(retried);
          } catch (_) { /* fall through */ }
        }

        if (error.response?.statusCode == 401) {
          final isAuthEndpoint = error.requestOptions.path.contains('/auth/');
          if (!isAuthEndpoint) {
            final refreshToken = await _storage.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                // Own Dio so a hung /auth/refresh can never block everything.
                final refreshDio = Dio(BaseOptions(
                  baseUrl: Env.apiUrl,
                  connectTimeout: const Duration(seconds: 10),
                  receiveTimeout: const Duration(seconds: 15),
                  sendTimeout: const Duration(seconds: 10),
                  headers: {'X-Tenant': Env.tenant},
                ));
                final refreshRes = await refreshDio.post('/auth/refresh',
                    data: {'refreshToken': refreshToken});
                final data = refreshRes.data?['data'] as Map<String, dynamic>?;
                final newAccess = data?['accessToken'] as String?;
                final newRefresh = data?['refreshToken'] as String?;
                if (newAccess != null) {
                  await _storage.saveAccessToken(newAccess);
                  if (newRefresh != null) await _storage.saveRefreshToken(newRefresh);
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                  final retried = await _dio.fetch(error.requestOptions);
                  return handler.resolve(retried);
                }
              } catch (e) {
                debugPrint('Refresh failed: $e — clearing session');
              }
            }
            await _storage.clearAll();
            onSessionExpired?.call();
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.get(path, queryParameters: queryParameters, options: options);
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
}
