import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';
import '../models/app_data.dart';
import '../models/category.dart';
import '../models/todo_item.dart';
import '../services/storage_service.dart';

class TodoController extends ChangeNotifier {
  final StorageService _storageService;
  static const _uuid = Uuid();

  List<Category> _categories = [];
  List<TodoItem> _todos = [];
  bool _isLoading = true;

  final Set<String> _selectedActiveIds = {};
  final Set<String> _selectedCompletedIds = {};

  TodoController({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  bool get isLoading => _isLoading;
  List<Category> get categories {
    final list = List<Category>.from(_categories);
    list.sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(list);
  }

  List<TodoItem> get allTodos => List.unmodifiable(_todos);

  Set<String> get selectedActiveIds => Set.unmodifiable(_selectedActiveIds);
  Set<String> get selectedCompletedIds => Set.unmodifiable(_selectedCompletedIds);

  bool isSelectionActive(bool isCompleted) =>
      isCompleted ? _selectedCompletedIds.isNotEmpty : _selectedActiveIds.isNotEmpty;

  int getSelectionCount(bool isCompleted) =>
      isCompleted ? _selectedCompletedIds.length : _selectedActiveIds.length;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final data = await _storageService.loadData();
    _categories = List<Category>.from(data.categories);
    _todos = List<TodoItem>.from(data.todos);
    _normalizeOrders();

    _isLoading = false;
    notifyListeners();
  }

  // --- Category Operations ---

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addCategory({
    required String name,
    required int colorValue,
    required int iconCodePoint,
  }) async {
    final nextOrder = _categories.isEmpty
        ? 0
        : (_categories.map((c) => c.order).reduce((a, b) => a > b ? a : b) + 1);

    final category = Category(
      id: _uuid.v4(),
      name: name.trim(),
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      order: nextOrder,
      createdAt: DateTime.now(),
    );

    _categories.add(category);
    await _persistAndNotify();
  }

  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      await _persistAndNotify();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
    _todos.removeWhere((t) => t.categoryId == categoryId);
    _selectedActiveIds.clear();
    _selectedCompletedIds.clear();
    _normalizeOrders();
    await _persistAndNotify();
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final sorted = List<Category>.from(categories);
    if (oldIndex >= sorted.length || newIndex >= sorted.length) return;

    final item = sorted.removeAt(oldIndex);
    sorted.insert(newIndex, item);

    _categories = [
      for (int i = 0; i < sorted.length; i++) sorted[i].copyWith(order: i)
    ];

    await _persistAndNotify();
  }

  // --- Task Operations ---

  List<TodoItem> getActiveTodos(String categoryId) {
    final list = _todos
        .where((t) => t.categoryId == categoryId && !t.isCompleted)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<TodoItem> getCompletedTodos(String categoryId) {
    final list = _todos
        .where((t) => t.categoryId == categoryId && t.isCompleted)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  int getActiveCount(String categoryId) =>
      _todos.where((t) => t.categoryId == categoryId && !t.isCompleted).length;

  int getCompletedCount(String categoryId) =>
      _todos.where((t) => t.categoryId == categoryId && t.isCompleted).length;

  Future<void> addTodo({
    required String categoryId,
    required String title,
    String description = '',
    DateTime? dueDate,
  }) async {
    final active = getActiveTodos(categoryId);
    final nextOrder = active.isEmpty
        ? 0
        : (active.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1);

    final todo = TodoItem(
      id: _uuid.v4(),
      categoryId: categoryId,
      title: title.trim(),
      description: description.trim(),
      isCompleted: false,
      order: nextOrder,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );

    _todos.add(todo);
    await _persistAndNotify();
  }

  Future<void> updateTodo(TodoItem updatedItem) async {
    final index = _todos.indexWhere((t) => t.id == updatedItem.id);
    if (index != -1) {
      _todos[index] = updatedItem;
      await _persistAndNotify();
    }
  }

  Future<void> toggleTodoComplete(String todoId) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index != -1) {
      final current = _todos[index];
      final willBeCompleted = !current.isCompleted;

      final targetList = willBeCompleted
          ? getCompletedTodos(current.categoryId)
          : getActiveTodos(current.categoryId);
      final nextOrder = targetList.isEmpty
          ? 0
          : (targetList.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1);

      _todos[index] = current.copyWith(
        isCompleted: willBeCompleted,
        order: nextOrder,
        completedAt: willBeCompleted ? DateTime.now() : null,
        clearCompletedAt: !willBeCompleted,
      );

      _selectedActiveIds.remove(todoId);
      _selectedCompletedIds.remove(todoId);
      _normalizeOrdersForCategory(current.categoryId);
      await _persistAndNotify();
    }
  }

  Future<void> deleteTodo(String todoId) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index != -1) {
      final categoryId = _todos[index].categoryId;
      _todos.removeAt(index);
      _selectedActiveIds.remove(todoId);
      _selectedCompletedIds.remove(todoId);
      _normalizeOrdersForCategory(categoryId);
      await _persistAndNotify();
    }
  }

  Future<void> reorderActiveTodos(String categoryId, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final active = getActiveTodos(categoryId);
    if (oldIndex >= active.length || newIndex >= active.length) return;

    final item = active.removeAt(oldIndex);
    active.insert(newIndex, item);

    for (int i = 0; i < active.length; i++) {
      final indexInMain = _todos.indexWhere((t) => t.id == active[i].id);
      if (indexInMain != -1) {
        _todos[indexInMain] = active[i].copyWith(order: i);
      }
    }

    await _persistAndNotify();
  }

  Future<void> reorderCompletedTodos(String categoryId, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final completed = getCompletedTodos(categoryId);
    if (oldIndex >= completed.length || newIndex >= completed.length) return;

    final item = completed.removeAt(oldIndex);
    completed.insert(newIndex, item);

    for (int i = 0; i < completed.length; i++) {
      final indexInMain = _todos.indexWhere((t) => t.id == completed[i].id);
      if (indexInMain != -1) {
        _todos[indexInMain] = completed[i].copyWith(order: i);
      }
    }

    await _persistAndNotify();
  }

  // --- Multi-Selection & Batch Actions ---

  void toggleSelection(String id, {required bool isCompleted}) {
    final set = isCompleted ? _selectedCompletedIds : _selectedActiveIds;
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    notifyListeners();
  }

  bool isItemSelected(String id, {required bool isCompleted}) {
    return isCompleted
        ? _selectedCompletedIds.contains(id)
        : _selectedActiveIds.contains(id);
  }

  void selectAll(String categoryId, {required bool isCompleted}) {
    final items = isCompleted ? getCompletedTodos(categoryId) : getActiveTodos(categoryId);
    final set = isCompleted ? _selectedCompletedIds : _selectedActiveIds;
    if (set.length == items.length) {
      set.clear();
    } else {
      set.clear();
      set.addAll(items.map((t) => t.id));
    }
    notifyListeners();
  }

  void clearSelection({bool? isCompleted}) {
    if (isCompleted == null) {
      _selectedActiveIds.clear();
      _selectedCompletedIds.clear();
    } else if (isCompleted) {
      _selectedCompletedIds.clear();
    } else {
      _selectedActiveIds.clear();
    }
    notifyListeners();
  }

  Future<void> batchCompleteSelected() async {
    if (_selectedActiveIds.isEmpty) return;

    final now = DateTime.now();
    for (int i = 0; i < _todos.length; i++) {
      if (_selectedActiveIds.contains(_todos[i].id)) {
        _todos[i] = _todos[i].copyWith(
          isCompleted: true,
          completedAt: now,
        );
      }
    }

    _selectedActiveIds.clear();
    _normalizeOrders();
    await _persistAndNotify();
  }

  Future<void> batchRestoreSelected() async {
    if (_selectedCompletedIds.isEmpty) return;

    for (int i = 0; i < _todos.length; i++) {
      if (_selectedCompletedIds.contains(_todos[i].id)) {
        _todos[i] = _todos[i].copyWith(
          isCompleted: false,
          clearCompletedAt: true,
        );
      }
    }

    _selectedCompletedIds.clear();
    _normalizeOrders();
    await _persistAndNotify();
  }

  Future<void> batchDeleteSelected({required bool isCompleted}) async {
    final set = isCompleted ? _selectedCompletedIds : _selectedActiveIds;
    if (set.isEmpty) return;

    _todos.removeWhere((t) => set.contains(t.id));
    set.clear();
    _normalizeOrders();
    await _persistAndNotify();
  }

  // --- Import / Export ---

  String exportToJson() {
    final data = AppData(
      schemaVersion: AppData.currentSchemaVersion,
      exportedAt: DateTime.now(),
      categories: _categories,
      todos: _todos,
    );
    return data.toPrettyJson();
  }

  Future<void> importData(AppData incomingData, {required bool replaceAll}) async {
    if (replaceAll) {
      _categories = List<Category>.from(incomingData.categories);
      _todos = List<TodoItem>.from(incomingData.todos);
    } else {
      final categoryMap = {for (var c in _categories) c.id: c};
      for (var c in incomingData.categories) {
        categoryMap[c.id] = c;
      }
      _categories = categoryMap.values.toList();

      final todoMap = {for (var t in _todos) t.id: t};
      for (var t in incomingData.todos) {
        todoMap[t.id] = t;
      }
      _todos = todoMap.values.toList();
    }

    _selectedActiveIds.clear();
    _selectedCompletedIds.clear();
    _normalizeOrders();
    await _persistAndNotify();
  }

  // --- Helpers ---

  void _normalizeOrders() {
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(order: i);
    }
    for (var cat in _categories) {
      _normalizeOrdersForCategory(cat.id);
    }
  }

  void _normalizeOrdersForCategory(String categoryId) {
    final active = getActiveTodos(categoryId);
    for (int i = 0; i < active.length; i++) {
      final idx = _todos.indexWhere((t) => t.id == active[i].id);
      if (idx != -1) _todos[idx] = _todos[idx].copyWith(order: i);
    }

    final completed = getCompletedTodos(categoryId);
    for (int i = 0; i < completed.length; i++) {
      final idx = _todos.indexWhere((t) => t.id == completed[i].id);
      if (idx != -1) _todos[idx] = _todos[idx].copyWith(order: i);
    }
  }

  Future<void> _persistAndNotify() async {
    notifyListeners();
    final data = AppData(
      schemaVersion: AppData.currentSchemaVersion,
      exportedAt: DateTime.now(),
      categories: _categories,
      todos: _todos,
    );
    await _storageService.saveData(data);
  }
}
