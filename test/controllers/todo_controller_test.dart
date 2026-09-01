import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/controllers/todo_controller.dart';
import 'package:flutter_todo/models/app_data.dart';
import 'package:flutter_todo/models/category.dart';
import 'package:flutter_todo/models/todo_item.dart';
import 'package:flutter_todo/services/storage_service.dart';

class InMemoryStorageService extends StorageService {
  AppData _data = AppData.empty();

  @override
  Future<AppData> loadData() async => _data;

  @override
  Future<bool> saveData(AppData data) async {
    _data = data;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TodoController Logic Tests', () {
    late TodoController controller;
    late InMemoryStorageService storage;

    setUp(() async {
      storage = InMemoryStorageService();
      controller = TodoController(storageService: storage);
      await controller.init();
    });

    test('addCategory and deleteCategory with cascade', () async {
      expect(controller.categories, isEmpty);

      await controller.addCategory(
        name: 'Urgent',
        colorValue: 0xFFFF0000,
        iconCodePoint: 100,
      );

      expect(controller.categories.length, equals(1));
      final catId = controller.categories.first.id;

      await controller.addTodo(
        categoryId: catId,
        title: 'Task 1',
      );
      await controller.addTodo(
        categoryId: catId,
        title: 'Task 2',
      );

      expect(controller.getActiveTodos(catId).length, equals(2));

      // Deleting category cascades deletion to its tasks
      await controller.deleteCategory(catId);
      expect(controller.categories, isEmpty);
      expect(controller.allTodos, isEmpty);
    });

    test('toggle completion moves task between active and completed', () async {
      await controller.addCategory(
        name: 'Daily',
        colorValue: 0xFF00FF00,
        iconCodePoint: 100,
      );
      final catId = controller.categories.first.id;

      await controller.addTodo(categoryId: catId, title: 'Buy milk');
      expect(controller.getActiveTodos(catId).length, equals(1));
      expect(controller.getCompletedTodos(catId), isEmpty);

      final taskId = controller.getActiveTodos(catId).first.id;

      // Mark complete
      await controller.toggleTodoComplete(taskId);
      expect(controller.getActiveTodos(catId), isEmpty);
      expect(controller.getCompletedTodos(catId).length, equals(1));
      expect(controller.getCompletedTodos(catId).first.completedAt, isNotNull);

      // Uncomplete / Restore
      await controller.toggleTodoComplete(taskId);
      expect(controller.getActiveTodos(catId).length, equals(1));
      expect(controller.getCompletedTodos(catId), isEmpty);
      expect(controller.getActiveTodos(catId).first.completedAt, isNull);
    });

    test('batch complete, restore, and delete operations', () async {
      await controller.addCategory(
        name: 'Projects',
        colorValue: 0xFF0000FF,
        iconCodePoint: 100,
      );
      final catId = controller.categories.first.id;

      await controller.addTodo(categoryId: catId, title: 'T1');
      await controller.addTodo(categoryId: catId, title: 'T2');
      await controller.addTodo(categoryId: catId, title: 'T3');

      final active = controller.getActiveTodos(catId);
      controller.toggleSelection(active[0].id, isCompleted: false);
      controller.toggleSelection(active[1].id, isCompleted: false);

      expect(controller.getSelectionCount(false), equals(2));

      // Batch complete 2 tasks
      await controller.batchCompleteSelected();
      expect(controller.getActiveTodos(catId).length, equals(1));
      expect(controller.getCompletedTodos(catId).length, equals(2));

      // Batch restore 1 task
      final completed = controller.getCompletedTodos(catId);
      controller.toggleSelection(completed[0].id, isCompleted: true);
      await controller.batchRestoreSelected();
      expect(controller.getActiveTodos(catId).length, equals(2));
      expect(controller.getCompletedTodos(catId).length, equals(1));

      // Batch permanent delete
      final remainingCompleted = controller.getCompletedTodos(catId);
      controller.toggleSelection(remainingCompleted[0].id, isCompleted: true);
      await controller.batchDeleteSelected(isCompleted: true);
      expect(controller.getCompletedTodos(catId), isEmpty);
    });

    test('reorderActiveTodos changes sequence order correctly', () async {
      await controller.addCategory(
        name: 'Sort Test',
        colorValue: 0xFF0000FF,
        iconCodePoint: 100,
      );
      final catId = controller.categories.first.id;

      await controller.addTodo(categoryId: catId, title: 'First');
      await controller.addTodo(categoryId: catId, title: 'Second');
      await controller.addTodo(categoryId: catId, title: 'Third');

      expect(controller.getActiveTodos(catId).map((t) => t.title).toList(),
          equals(['First', 'Second', 'Third']));

      // Move First (0) to position after Second (2)
      await controller.reorderActiveTodos(catId, 0, 2);

      expect(controller.getActiveTodos(catId).map((t) => t.title).toList(),
          equals(['Second', 'First', 'Third']));
    });

    test('importData replace and merge modes', () async {
      final now = DateTime.now();
      final importData = AppData(
        schemaVersion: 1,
        exportedAt: now,
        categories: [
          Category(
            id: 'imported-c1',
            name: 'Imported Cat',
            colorValue: 0xFF112233,
            iconCodePoint: 50,
            order: 0,
            createdAt: now,
          ),
        ],
        todos: [
          TodoItem(
            id: 'imported-t1',
            categoryId: 'imported-c1',
            title: 'Imported Task',
            order: 0,
            createdAt: now,
          ),
        ],
      );

      // Replace All
      await controller.importData(importData, replaceAll: true);
      expect(controller.categories.length, equals(1));
      expect(controller.categories.first.name, equals('Imported Cat'));
      expect(controller.allTodos.length, equals(1));

      // Merge
      final mergeData = AppData(
        schemaVersion: 1,
        exportedAt: now,
        categories: [
          Category(
            id: 'imported-c2',
            name: 'Second Cat',
            colorValue: 0xFF445566,
            iconCodePoint: 60,
            order: 1,
            createdAt: now,
          ),
        ],
        todos: [],
      );

      await controller.importData(mergeData, replaceAll: false);
      expect(controller.categories.length, equals(2));
      expect(controller.allTodos.length, equals(1));
    });
  });
}
