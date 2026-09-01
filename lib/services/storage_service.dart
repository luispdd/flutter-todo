import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_data.dart';
import '../models/category.dart';
import '../models/todo_item.dart';

class StorageService {
  static const String _storageKey = 'flutter_todo_app_data_v1';
  static const _uuid = Uuid();

  Future<AppData> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        return AppData.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    }

    return _generateDefaultStarterData();
  }

  Future<bool> saveData(AppData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(data.toJson());
      return await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('Error saving to storage: $e');
      return false;
    }
  }

  Future<bool> clearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      return false;
    }
  }

  static AppData _generateDefaultStarterData() {
    final now = DateTime.now();
    final personalCatId = _uuid.v4();
    final workCatId = _uuid.v4();
    final shoppingCatId = _uuid.v4();

    final categories = [
      Category(
        id: personalCatId,
        name: 'Personal',
        colorValue: Colors.indigo.value,
        iconCodePoint: Icons.person_rounded.codePoint,
        order: 0,
        createdAt: now,
      ),
      Category(
        id: workCatId,
        name: 'Work',
        colorValue: Colors.teal.value,
        iconCodePoint: Icons.work_rounded.codePoint,
        order: 1,
        createdAt: now,
      ),
      Category(
        id: shoppingCatId,
        name: 'Shopping & Errands',
        colorValue: Colors.amber.shade800.value,
        iconCodePoint: Icons.shopping_cart_rounded.codePoint,
        order: 2,
        createdAt: now,
      ),
    ];

    final todos = [
      TodoItem(
        id: _uuid.v4(),
        categoryId: personalCatId,
        title: 'Welcome to Flutter ToDo!',
        description: 'Drag tasks up and down to reorder your priorities.',
        isCompleted: false,
        order: 0,
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      TodoItem(
        id: _uuid.v4(),
        categoryId: personalCatId,
        title: 'Try selecting multiple tasks',
        description: 'Tap selection checkboxes to batch complete, restore, or delete tasks.',
        isCompleted: false,
        order: 1,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      TodoItem(
        id: _uuid.v4(),
        categoryId: personalCatId,
        title: 'Test Clipboard Import / Export',
        description: 'Backup your tasks into a JSON string anytime via the clipboard icon.',
        isCompleted: true,
        order: 0,
        createdAt: now.subtract(const Duration(hours: 1)),
        completedAt: now.subtract(const Duration(minutes: 2)),
      ),
    ];

    return AppData(
      exportedAt: now,
      categories: categories,
      todos: todos,
    );
  }
}
