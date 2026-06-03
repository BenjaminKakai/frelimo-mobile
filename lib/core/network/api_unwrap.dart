/// Tiny helpers for the `{success, data, timestamp}` envelope every backend
/// endpoint returns. Use these instead of touching `response.data` directly
/// — keeps the parsing logic in one place and accommodates the loose typing
/// the backend has historically returned (sometimes a list, sometimes
/// `{items: [...]}` with pagination metadata).
class ApiUnwrap {
  /// Pull the `data` field out of the envelope. Returns null if absent.
  static dynamic data(dynamic body) {
    if (body is Map) return body['data'];
    return null;
  }

  /// Extract a list from `data` whether it's `[...]` or `{items: [...]}`.
  static List<Map<String, dynamic>> list(dynamic body) {
    final d = data(body);
    final raw = d is List ? d : (d is Map ? d['items'] : null);
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Extract a map from `data`.
  static Map<String, dynamic>? map(dynamic body) {
    final d = data(body);
    return d is Map ? Map<String, dynamic>.from(d) : null;
  }
}
