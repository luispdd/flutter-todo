import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_todo/services/screen_api_service.dart';

void main() {
  group('ScreenApiService Tests', () {
    test('fetchTasks returns list of tasks on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), equals('http://screen.local/tasks'));
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'text': 'Task 1',
              'done': false,
              'created_at': '2026-10-21 12:00',
            },
            {
              'id': 2,
              'text': 'Task 2',
              'done': true,
              'created_at': '2026-10-21 12:05',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ScreenApiService(client: mockClient);
      final tasks = await service.fetchTasks();

      expect(tasks.length, equals(2));
      expect(tasks[0].id, equals(1));
      expect(tasks[0].text, equals('Task 1'));
      expect(tasks[0].done, isFalse);
      expect(tasks[1].done, isTrue);
    });

    test('deleteTask sends DELETE and returns true on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(request.url.toString(), equals('http://screen.local/tasks/5'));
        return http.Response(jsonEncode({'status': 'deleted'}), 200);
      });

      final service = ScreenApiService(client: mockClient);
      final result = await service.deleteTask(5);
      expect(result, isTrue);
    });

    test('createTasks posts JSON array and returns created tasks', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.toString(), equals('http://screen.local/tasks'));
        final body = jsonDecode(request.body) as List;
        expect(body.length, equals(2));
        expect(body[0]['text'], equals('Buy milk'));

        return http.Response(
          jsonEncode([
            {
              'id': 10,
              'text': 'Buy milk',
              'done': false,
              'created_at': '2026-10-21 12:10',
            },
            {
              'id': 11,
              'text': 'Call Alice',
              'done': false,
              'created_at': '2026-10-21 12:11',
            },
          ]),
          201,
        );
      });

      final service = ScreenApiService(client: mockClient);
      final result = await service.createTasks(['Buy milk', 'Call Alice']);

      expect(result.length, equals(2));
      expect(result[0].id, equals(10));
    });

    test('fetchTasks throws exception on error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = ScreenApiService(client: mockClient);
      expect(() => service.fetchTasks(), throwsA(isA<Exception>()));
    });
  });
}
