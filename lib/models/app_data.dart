import 'dart:convert';
import 'category.dart';
import 'todo_item.dart';

class AppData {
  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime exportedAt;
  final List<Category> categories;
  final List<TodoItem> todos;

  const AppData({
    this.schemaVersion = currentSchemaVersion,
    required this.exportedAt,
    required this.categories,
    required this.todos,
  });

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'todos': todos.map((t) => t.toJson()).toList(),
    };
  }

  String toPrettyJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('categories') && !json.containsKey('todos')) {
      throw const FormatException('Missing required categories or todos');
    }

    final rawCategories = json['categories'] as List<dynamic>? ?? [];
    final categoriesList = rawCategories
        .map((c) => Category.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();

    final rawTodos = json['todos'] as List<dynamic>? ?? [];
    final todosList = rawTodos
        .map((t) => TodoItem.fromJson(Map<String, dynamic>.from(t as Map)))
        .toList();

    return AppData(
      schemaVersion: json['schemaVersion'] as int? ?? currentSchemaVersion,
      exportedAt: json['exportedAt'] != null
          ? DateTime.parse(json['exportedAt'] as String)
          : DateTime.now(),
      categories: categoriesList,
      todos: todosList,
    );
  }

  factory AppData.empty() {
    return AppData(
      exportedAt: DateTime.now(),
      categories: <Category>[],
      todos: <TodoItem>[],
    );
  }
}
