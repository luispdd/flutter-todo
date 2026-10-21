import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo/controllers/todo_controller.dart';
import 'package:flutter_todo/models/app_data.dart';
import 'package:flutter_todo/models/category.dart';
import 'package:flutter_todo/models/todo_item.dart';
import 'package:flutter_todo/services/storage_service.dart';
import 'package:flutter_todo/views/categories/categories_screen.dart';
import 'package:flutter_todo/views/tasks/category_tasks_screen.dart';
import 'package:flutter_todo/views/tasks/completed_tasks_view.dart';

class FakeStorageService extends StorageService {
  AppData data;
  String? lastActiveId;

  FakeStorageService({required this.data, this.lastActiveId});

  @override
  Future<AppData> loadData() async => data;

  @override
  Future<bool> saveData(AppData newData) async {
    data = newData;
    return true;
  }

  @override
  Future<String?> getLastActiveCategoryId() async => lastActiveId;

  @override
  Future<bool> setLastActiveCategoryId(String categoryId) async {
    lastActiveId = categoryId;
    return true;
  }

  @override
  Future<bool> clearLastActiveCategoryId() async {
    lastActiveId = null;
    return true;
  }
}

void main() {
  group('Category Sync and Restoration Tests', () {
    test('Category model preserves isApiSyncEnabled across toJson and fromJson', () {
      final category = Category(
        id: 'cat-1',
        name: 'Work',
        colorValue: 0xFF123456,
        iconCodePoint: 123,
        order: 0,
        createdAt: DateTime.now(),
        isApiSyncEnabled: true,
      );

      final json = category.toJson();
      expect(json['isApiSyncEnabled'], isTrue);

      final revived = Category.fromJson(json);
      expect(revived.isApiSyncEnabled, isTrue);

      final copy = category.copyWith(isApiSyncEnabled: false);
      expect(copy.isApiSyncEnabled, isFalse);
    });

    testWidgets('CompletedTasksView renders title in bold without strike-through',
        (WidgetTester tester) async {
      final category = Category(
        id: 'cat-1',
        name: 'Personal',
        colorValue: 0xFF123456,
        iconCodePoint: 123,
        order: 0,
        createdAt: DateTime.now(),
      );

      final completedItem = TodoItem(
        id: 'todo-1',
        categoryId: category.id,
        title: 'Completed Important Task',
        isCompleted: true,
        order: 0,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final storage = FakeStorageService(
        data: AppData(
          exportedAt: DateTime.now(),
          categories: [category],
          todos: [completedItem],
        ),
      );

      final controller = TodoController(storageService: storage);
      await controller.init();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TodoController>.value(
            value: controller,
            child: Scaffold(
              body: CompletedTasksView(category: category),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.text('Completed Important Task');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(textWidget.style?.decoration, isNot(TextDecoration.lineThrough));
    });

    testWidgets('CategoryTasksScreen shows sync buttons only when isApiSyncEnabled is true',
        (WidgetTester tester) async {
      final syncCategory = Category(
        id: 'cat-sync',
        name: 'Hardware Sync',
        colorValue: 0xFF123456,
        iconCodePoint: 123,
        order: 0,
        createdAt: DateTime.now(),
        isApiSyncEnabled: true,
      );

      final regularCategory = Category(
        id: 'cat-regular',
        name: 'Normal Category',
        colorValue: 0xFF654321,
        iconCodePoint: 456,
        order: 1,
        createdAt: DateTime.now(),
        isApiSyncEnabled: false,
      );

      final storage = FakeStorageService(
        data: AppData(
          exportedAt: DateTime.now(),
          categories: [syncCategory, regularCategory],
          todos: [],
        ),
      );

      final controller = TodoController(storageService: storage);
      await controller.init();

      // Test sync category
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TodoController>.value(
            value: controller,
            child: CategoryTasksScreen(categoryId: syncCategory.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pull from API'), findsOneWidget);
      expect(find.text('Push to API'), findsOneWidget);
      expect(find.text('Add Task'), findsOneWidget);

      // Re-pump with regular category
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TodoController>.value(
            value: controller,
            child: CategoryTasksScreen(categoryId: regularCategory.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pull from API'), findsNothing);
      expect(find.text('Push to API'), findsNothing);
      expect(find.text('Add Task'), findsOneWidget);
    });

    testWidgets('CategoriesScreen automatically navigates to last active category on launch',
        (WidgetTester tester) async {
      final category = Category(
        id: 'cat-auto',
        name: 'Auto Restored Category',
        colorValue: 0xFF123456,
        iconCodePoint: 123,
        order: 0,
        createdAt: DateTime.now(),
      );

      final storage = FakeStorageService(
        data: AppData(
          exportedAt: DateTime.now(),
          categories: [category],
          todos: [],
        ),
        lastActiveId: 'cat-auto',
      );

      final controller = TodoController(storageService: storage);
      await controller.init();

      await tester.pumpWidget(
        ChangeNotifierProvider<TodoController>.value(
          value: controller,
          child: MaterialApp(
            home: CategoriesScreen(
              onToggleTheme: () {},
              isDarkMode: false,
            ),
          ),
        ),
      );

      // Pump through post-frame callback
      await tester.pumpAndSettle();

      // Should have pushed CategoryTasksScreen displaying the category name in the AppBar
      expect(find.byType(CategoryTasksScreen), findsOneWidget);
      expect(find.text('Auto Restored Category'), findsWidgets);

      // Press back button to return to CategoriesScreen
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryTasksScreen), findsNothing);
      expect(find.text('Tasks & Categories'), findsOneWidget);
      expect(storage.lastActiveId, isNull);
    });
  });
}
