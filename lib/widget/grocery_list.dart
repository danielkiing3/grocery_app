import 'package:flutter/material.dart';
import 'package:grocery_app/junks/dummy_items.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/widget/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItem = [];

  /// Method response for loading data from the backend
  void _loadItem() async {
    final url = Uri.https(
      'flutter-grocery-c5f45-default-rtdb.firebaseio.com',
      'shopping_list.json',
    );
    final resposne = await http.get(url);
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    _loadItem();
  }

  void _removeItem(index) {
    setState(() {
      _groceryItem.remove(_groceryItem[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'No Item Added Yet.',
        style: TextStyle(fontSize: 32),
      ),
    );

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: ValueKey(groceryItems[index].id),
            onDismissed: (direction) {
              _removeItem(index);
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
