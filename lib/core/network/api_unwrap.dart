/// Helpers for reading a response body regardless of which shape the backend
/// wrapped it in. Use these instead of touching `response.data` directly.
///
/// The FRELIMO backend has NO global response interceptor: controllers return
/// their Prisma result straight out, so in practice three shapes reach us:
///
///   1. a bare list                      — `GET /engagement/surveys`, `/elections`
///   2. `{items, total, page, pageSize}`  — `GET /news/feed`
///   3. `{success, data, timestamp}`      — the envelope used by the other
///                                          Wasaa services, kept supported so
///                                          this app still works if FRELIMO
///                                          ever adopts it too
///
/// The previous version only understood shape 3 and returned an empty list for
/// 1 and 2 — which silently blanked the news, surveys and voting screens
/// against a server that had data. Everything below therefore unwraps the
/// envelope only if it is actually present, and otherwise reads the body as-is.
class ApiUnwrap {
  /// Strip the `{success, data, timestamp}` envelope if there is one, else
  /// hand back the body untouched. A `Map` counts as enveloped only when it
  /// really carries a `data` key — `{items: [...]}` must fall through as-is.
  static dynamic data(dynamic body) {
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  /// Extract a list of rows from a body that may be a bare list, an
  /// `{items: [...]}` page, or either of those inside an envelope.
  static List<Map<String, dynamic>> list(dynamic body) {
    final d = data(body);
    final raw = d is List
        ? d
        : (d is Map ? (d['items'] ?? d['results'] ?? d['rows']) : null);
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Extract a single object, unwrapping an envelope if present.
  static Map<String, dynamic>? map(dynamic body) {
    final d = data(body);
    return d is Map ? Map<String, dynamic>.from(d) : null;
  }
}
