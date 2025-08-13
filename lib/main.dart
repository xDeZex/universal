import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/shopping_list.dart';
import 'models/shopping_item.dart';
import 'screens/shopping_lists_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShoppingAppState(),
      child: MaterialApp(
        title: 'Shopping Lists',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('sv', ''),
        ],
        home: ShoppingListsScreen(),
      ),
    );
  }
}

class ShoppingAppState extends ChangeNotifier {
  List<ShoppingList> _shoppingLists = [];
  static const String _storageKey = 'shopping_lists';

  List<ShoppingList> get shoppingLists => _shoppingLists;

  ShoppingAppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _shoppingLists = jsonList
            .map((jsonItem) => ShoppingList.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        _shoppingLists.map((list) => list.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  void addShoppingList(String name) {
    final newList = ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      items: [],
      createdAt: DateTime.now(),
    );
    _shoppingLists.add(newList);
    _saveData();
    notifyListeners();
  }

  void deleteShoppingList(String id) {
    _shoppingLists.removeWhere((list) => list.id == id);
    _saveData();
    notifyListeners();
  }

  void addItemToList(String listId, String itemName) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final newItem = ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: itemName,
      );
      final updatedItems = List<ShoppingItem>.from(_shoppingLists[listIndex].items)..add(newItem);
      _shoppingLists[listIndex] = _shoppingLists[listIndex].copyWith(items: updatedItems);
      _saveData();
      notifyListeners();
    }
  }

  void toggleItemCompletion(String listId, String itemId) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final items = _shoppingLists[listIndex].items;
      final itemIndex = items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final updatedItems = List<ShoppingItem>.from(items);
        updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
          isCompleted: !updatedItems[itemIndex].isCompleted,
        );
        _shoppingLists[listIndex] = _shoppingLists[listIndex].copyWith(items: updatedItems);
        _saveData();
        notifyListeners();
      }
    }
  }

  void deleteItemFromList(String listId, String itemId) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final updatedItems = _shoppingLists[listIndex].items.where((item) => item.id != itemId).toList();
      _shoppingLists[listIndex] = _shoppingLists[listIndex].copyWith(items: updatedItems);
      _saveData();
      notifyListeners();
    }
  }

  void reorderItems(String listId, int oldIndex, int newIndex) {
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final items = List<ShoppingItem>.from(_shoppingLists[listIndex].items);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      _shoppingLists[listIndex] = _shoppingLists[listIndex].copyWith(items: items);
      _saveData();
      notifyListeners();
    }
  }
}