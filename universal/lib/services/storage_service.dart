import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checklist.dart';

class StorageService {
  static const String _checklistsKey = 'checklists';

  Future<List<Checklist>> loadChecklists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_checklistsKey);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Checklist.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveChecklists(List<Checklist> checklists) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = checklists.map((c) => c.toJson()).toList();
    await prefs.setString(_checklistsKey, jsonEncode(jsonList));
  }
}
