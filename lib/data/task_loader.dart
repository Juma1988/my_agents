import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/challenge_category.dart';

/// Loads and parses task.json from assets
class TaskLoader {
  TaskLoader._();

  /// Load all challenge categories from task.json
  static Future<List<ChallengeCategory>> loadCategories() async {
    try {
      final jsonString = await rootBundle.loadString('task.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final categoriesList = jsonData['categories'] as List;
      return categoriesList
          .map((e) => ChallengeCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback: return empty list on error
      return [];
    }
  }

  /// Load categories with retry logic (up to 3 attempts).
  /// Returns a [TaskLoadResult] indicating success or failure.
  static Future<TaskLoadResult> loadCategoriesWithRetry() async {
    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final categories = await loadCategories();
        if (categories.isNotEmpty) {
          return TaskLoadResult.success(categories);
        }
        // Empty result counts as a failure — retry
      } catch (e) {
        // Will retry on next iteration
      }
    }
    return TaskLoadResult.failure('Failed to load tasks after $maxAttempts attempts');
  }
}

/// Result of a task load operation.
class TaskLoadResult {
  final List<ChallengeCategory> categories;
  final String? errorMessage;

  const TaskLoadResult.success(this.categories) : errorMessage = null;
  const TaskLoadResult.failure(this.errorMessage) : categories = const [];

  bool get isSuccess => errorMessage == null;
}
