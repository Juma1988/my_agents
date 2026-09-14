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
}
