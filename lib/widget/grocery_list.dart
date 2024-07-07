import 'package:flutter/material.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/junks/dummy_items.dart';
import 'package:grocery_app/models/category.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItem = [];

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
