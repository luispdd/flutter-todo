import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/app_data.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final AppData? data;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.data,
  });

  factory ValidationResult.success(AppData data) => ValidationResult(
        isValid: true,
        data: data,
      );

  factory ValidationResult.failure(String message) => ValidationResult(
        isValid: false,
        errorMessage: message,
      );
}

class ClipboardService {
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String?> pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  ValidationResult validateJson(String rawJson) {
    if (rawJson.trim().isEmpty) {
      return ValidationResult.failure('Input cannot be empty.');
    }

    try {
      final dynamic decoded = jsonDecode(rawJson.trim());
      if (decoded is! Map) {
        return ValidationResult.failure('JSON root must be an object.');
      }

      final map = Map<String, dynamic>.from(decoded);
      if (!map.containsKey('categories') && !map.containsKey('todos')) {
        return ValidationResult.failure('Missing required categories or todos arrays.');
      }

      final appData = AppData.fromJson(map);
      return ValidationResult.success(appData);
    } on FormatException catch (e) {
      return ValidationResult.failure('Syntax error: ${e.message}');
    } catch (e) {
      return ValidationResult.failure('Validation failed: $e');
    }
  }
}
