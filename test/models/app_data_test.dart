import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/models/app_data.dart';
import 'package:flutter_todo/models/category.dart';
import 'package:flutter_todo/models/todo_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppData Serialization Tests', () {
    test('Category toJson and fromJson round-trip', () {
      final fixedDate = DateTime.utc(2026, 9, 1, 12, 0, 0);
      final category = Category(
        id: 'cat-1',
        name: 'Work',
        colorValue: 0xFF009688,
        iconCodePoint: 0xe39d,
        order: 0,
        createdAt: fixedDate,
      );

      final json = category.toJson();
      final restored = Category.fromJson(json);

      expect(restored.id, equals('cat-1'));
      expect(restored.name, equals('Work'));
      expect(restored.colorValue, equals(0xFF009688));
      expect(restored.iconCodePoint, equals(0xe39d));
      expect(restored.order, equals(0));
      expect(restored.createdAt.toIso8601String(), equals(fixedDate.toIso8601String()));
    });

    test('TodoItem toJson and fromJson round-trip', () {
      final fixedDate = DateTime.utc(2026, 9, 1, 12, 0, 0);
      final dueDate = DateTime.utc(2026, 9, 4, 12, 0, 0);
      final completedAt = DateTime.utc(2026, 9, 1, 13, 0, 0);

      final todo = TodoItem(
        id: 'todo-1',
        categoryId: 'cat-1',
        title: 'Review pull request',
        description: 'Check testing coverage',
        isCompleted: true,
        order: 2,
        createdAt: fixedDate,
        completedAt: completedAt,
        dueDate: dueDate,
      );

      final json = todo.toJson();
      final restored = TodoItem.fromJson(json);

      expect(restored.id, equals('todo-1'));
      expect(restored.categoryId, equals('cat-1'));
      expect(restored.title, equals('Review pull request'));
      expect(restored.description, equals('Check testing coverage'));
      expect(restored.isCompleted, isTrue);
      expect(restored.order, equals(2));
      expect(restored.dueDate?.toIso8601String(), equals(dueDate.toIso8601String()));
      expect(restored.completedAt?.toIso8601String(), equals(completedAt.toIso8601String()));
    });

    test('AppData full JSON serialization and deserialization', () {
      final fixedDate = DateTime.utc(2026, 9, 1, 12, 0, 0);
      final appData = AppData(
        schemaVersion: 1,
        exportedAt: fixedDate,
        categories: [
          Category(
            id: 'c1',
            name: 'Personal',
            colorValue: 0xFF123456,
            iconCodePoint: 123,
            order: 0,
            createdAt: fixedDate,
          ),
        ],
        todos: [
          TodoItem(
            id: 't1',
            categoryId: 'c1',
            title: 'Test task',
            order: 0,
            createdAt: fixedDate,
          ),
        ],
      );

      final prettyJson = appData.toPrettyJson();
      final Map<String, dynamic> decoded = jsonDecode(prettyJson);
      final restored = AppData.fromJson(decoded);

      expect(restored.schemaVersion, equals(1));
      expect(restored.categories.length, equals(1));
      expect(restored.categories.first.name, equals('Personal'));
      expect(restored.todos.length, equals(1));
      expect(restored.todos.first.title, equals('Test task'));
    });
  });
}
