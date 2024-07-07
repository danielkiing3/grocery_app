import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/widget/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  /// Method response for loading data from the backend
  void _loadItem() async {
    final url = Uri.https(
      'flutter-grocery-c5f45-default-rtdb.firebaseio.com',
      'shopping_list.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItem = loadItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItem.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItem.indexOf(item);
    setState(() {
      _groceryItem.remove(item);
    });

    final url = Uri.https(
      'flutter-grocery-c5f45-default-rtdb.firebaseio.com',
      'shopping_list/${item.id}.json',
    );
    final response = await http.delete(
      url,
    );

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 2000),
          content: Text(
            'Unable to connect to server',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _groceryItem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'No Item Added Yet.',
        style: TextStyle(fontSize: 16),
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: ValueKey(_groceryItem[index].id),
            onDismissed: (direction) {
              _removeItem(_groceryItem[index]);
            },
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.only(right: 5, left: 5),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.cancel),
                  Icon(Icons.cancel),
                ],
              ),
            ),
            child: ListTile(
              key: ValueKey(_groceryItem[index].id),
              leading: Container(
                height: 24,
                width: 24,
                color: _groceryItem[index].category.color,
              ),
              title: Text(_groceryItem[index].name),
              trailing: Text(_groceryItem[index].quantity.toString()),
            ),
          );
        },
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: content);
  }
}
