import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo/controllers/todo_controller.dart';
import 'package:flutter_todo/main.dart';
import 'package:flutter_todo/models/app_data.dart';
import 'package:flutter_todo/services/storage_service.dart';

class MockStorageService extends StorageService {
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
  testWidgets('TodoApp renders CategoriesScreen and opens CategoryDialog',
      (WidgetTester tester) async {
    final storageService = MockStorageService();
    final todoController = TodoController(storageService: storageService);
    await todoController.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<TodoController>.value(
        value: todoController,
        child: const TodoApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify main screen header
    expect(find.text('Tasks & Categories'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap the FAB to open the New Category dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify Category dialog form fields are present
    expect(find.text('Category Name'), findsOneWidget);
    expect(find.text('Color Theme'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create'), findsOneWidget);
  });
}
