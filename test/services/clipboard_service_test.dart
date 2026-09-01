import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/services/clipboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ClipboardService JSON Validation Tests', () {
    final clipboardService = ClipboardService();

    test('validates correctly formatted AppData JSON', () {
      const validJson = '''
      {
        "schemaVersion": 1,
        "exportedAt": "2026-09-01T12:00:00.000Z",
        "categories": [
          {
            "id": "c1",
            "name": "Work",
            "colorValue": 4282464437,
            "iconCodePoint": 58835,
            "order": 0,
            "createdAt": "2026-09-01T12:00:00.000Z"
          }
        ],
        "todos": [
          {
            "id": "t1",
            "categoryId": "c1",
            "title": "Finish report",
            "description": "Urgent",
            "isCompleted": false,
            "order": 0,
            "createdAt": "2026-09-01T12:00:00.000Z"
          }
        ]
      }
      ''';

      final result = clipboardService.validateJson(validJson);
      expect(result.isValid, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.categories.length, equals(1));
      expect(result.data!.todos.length, equals(1));
    });

    test('rejects empty or whitespace-only input', () {
      final result = clipboardService.validateJson('   ');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('rejects malformed syntax JSON', () {
      final result = clipboardService.validateJson('{ bad json : 123 ');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('rejects JSON missing required collections', () {
      final result = clipboardService.validateJson('{"otherKey": 123}');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });
  });
}
