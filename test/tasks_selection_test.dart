import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo/controllers/todo_controller.dart';
import 'package:flutter_todo/models/app_data.dart';
import 'package:flutter_todo/models/category.dart';
import 'package:flutter_todo/models/todo_item.dart';
import 'package:flutter_todo/services/storage_service.dart';
import 'package:flutter_todo/views/tasks/category_tasks_screen.dart';

class MockStorageService extends StorageService {
  AppData _data;

  MockStorageService(this._data);

  @override
  Future<AppData> loadData() async => _data;

  @override
  Future<bool> saveData(AppData data) async {
    _data = data;
    return true;
  }
}

void main() {
  late Category testCategory;
  late TodoItem activeTodo;
  late TodoItem completedTodo;
  late TodoController todoController;

  setUp(() async {
    testCategory = Category(
      id: 'cat-1',
      name: 'Work',
      colorValue: Colors.blue.toARGB32(),
      iconCodePoint: Icons.work.codePoint,
      order: 0,
      createdAt: DateTime.now(),
    );

    activeTodo = TodoItem(
      id: 'todo-1',
      categoryId: 'cat-1',
      title: 'Write report',
      description: 'Monthly report',
      isCompleted: false,
      order: 0,
      createdAt: DateTime.now(),
    );

    completedTodo = TodoItem(
      id: 'todo-2',
      categoryId: 'cat-1',
      title: 'Submit invoice',
      description: 'For client',
      isCompleted: true,
      order: 0,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    final appData = AppData(
      schemaVersion: 1,
      exportedAt: DateTime.now(),
      categories: [testCategory],
      todos: [activeTodo, completedTodo],
    );

    final storage = MockStorageService(appData);
    todoController = TodoController(storageService: storage);
    await todoController.init();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<TodoController>.value(
        value: todoController,
        child: CategoryTasksScreen(categoryId: testCategory.id),
      ),
    );
  }

  testWidgets('Active task has Checkbox and tapping body toggles selection without opening edit dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify task title is displayed
    expect(find.text('Write report'), findsOneWidget);

    // Verify checkbox is present and initially unchecked
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);
    Checkbox checkbox = tester.widget(checkboxFinder);
    expect(checkbox.value, isFalse);

    // Bottom action bar should NOT be visible
    expect(find.widgetWithText(FilledButton, 'Complete'), findsNothing);

    // Tap on the task body (card)
    await tester.tap(find.text('Write report'));
    await tester.pumpAndSettle();

    // Verify task is now selected (checkbox checked)
    checkbox = tester.widget(find.byType(Checkbox));
    expect(checkbox.value, isTrue);

    // Edit dialog should NOT be open
    expect(find.text('Edit Task'), findsNothing);

    // Bottom action bar should appear with full-width Complete button
    expect(find.widgetWithText(FilledButton, 'Complete'), findsOneWidget);

    // Verify NO delete button is shown in bottom bar for active tasks selection
    expect(find.widgetWithIcon(FilledButton, Icons.delete_forever_rounded), findsNothing);

    // Tap Complete button
    await tester.tap(find.widgetWithText(FilledButton, 'Complete'));
    await tester.pumpAndSettle();

    // Task is now moved to completed
    expect(find.text('Write report'), findsNothing);
    expect(find.text('No active tasks in Work'), findsOneWidget);
  });

  testWidgets('Tapping Edit icon strictly opens Edit dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Edit button on active task
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // Verify TaskDialog opens
    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save Changes'), findsOneWidget);
  });

  testWidgets('Completed task selection displays Reactivate and Permanently Delete buttons at bottom',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Switch to Completed tab
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();

    // Verify completed item
    expect(find.text('Submit invoice'), findsOneWidget);

    // Tap completed item to select
    await tester.tap(find.text('Submit invoice'));
    await tester.pumpAndSettle();

    // Verify bottom action bar shows Reactivate and Delete buttons
    expect(find.widgetWithText(FilledButton, 'Reactivate'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Delete'), findsOneWidget);

    // Tap Reactivate
    await tester.tap(find.widgetWithText(FilledButton, 'Reactivate'));
    await tester.pumpAndSettle();

    // Should now have no completed tasks
    expect(find.text('No completed tasks yet'), findsOneWidget);

    // Switch back to Active tab and verify it was restored
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(find.text('Submit invoice'), findsOneWidget);
  });
}
