import 'package:flutter_test/flutter_test.dart';
import 'package:frelimo_app/core/network/api_unwrap.dart';

/// The backend has no global response interceptor, so different endpoints
/// hand back different shapes. These cases are taken from real responses:
///
///   GET /news/feed            -> {items, total, page, pageSize}
///   GET /engagement/surveys   -> [ ... ]
///   GET /elections            -> [ ... ]
///
/// A previous version of ApiUnwrap only understood the `{success, data}`
/// envelope and returned an empty list for the first two — which silently
/// blanked the news, surveys and voting screens against a server that had
/// data. These tests exist to stop that regressing.
void main() {
  group('ApiUnwrap.list', () {
    test('reads a bare list (GET /engagement/surveys, /elections)', () {
      final body = [
        {'id': 'a', 'title': 'Survey A'},
        {'id': 'b', 'title': 'Survey B'},
      ];
      final out = ApiUnwrap.list(body);
      expect(out, hasLength(2));
      expect(out.first['title'], 'Survey A');
    });

    test('reads a paginated page (GET /news/feed)', () {
      final body = {
        'items': [
          {'id': '1', 'slug': 'first', 'title': 'First article'},
        ],
        'total': 1,
        'page': 1,
        'pageSize': 20,
      };
      final out = ApiUnwrap.list(body);
      expect(out, hasLength(1));
      expect(out.first['slug'], 'first');
    });

    test('still reads the {success, data, timestamp} envelope', () {
      final body = {
        'success': true,
        'data': [
          {'id': 'x'},
        ],
        'timestamp': '2026-09-28T00:00:00.000Z',
      };
      expect(ApiUnwrap.list(body), hasLength(1));
    });

    test('reads a page nested inside an envelope', () {
      final body = {
        'success': true,
        'data': {
          'items': [
            {'id': 'y'},
          ],
        },
      };
      expect(ApiUnwrap.list(body), hasLength(1));
    });

    test('returns empty for null, a scalar, or an unrecognised map', () {
      expect(ApiUnwrap.list(null), isEmpty);
      expect(ApiUnwrap.list('nope'), isEmpty);
      expect(ApiUnwrap.list({'unexpected': 1}), isEmpty);
    });

    test('skips non-map entries rather than throwing', () {
      final out = ApiUnwrap.list([
        {'id': 'ok'},
        'junk',
        42,
      ]);
      expect(out, hasLength(1));
    });
  });

  group('ApiUnwrap.map', () {
    test('reads a bare object (GET /news/article/:slug)', () {
      final out = ApiUnwrap.map({'id': 'a', 'title': 'An article'});
      expect(out?['title'], 'An article');
    });

    test('unwraps an enveloped object', () {
      final out = ApiUnwrap.map({
        'success': true,
        'data': {'id': 'a', 'title': 'Enveloped'},
      });
      expect(out?['title'], 'Enveloped');
    });

    test('returns null for a list or a scalar', () {
      expect(ApiUnwrap.map([1, 2]), isNull);
      expect(ApiUnwrap.map('nope'), isNull);
    });
  });
}
