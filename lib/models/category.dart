import 'package:flutter/material.dart';

/// Enum bucket to group different type of times in a grocery list
enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

/// Model what each Category for the grocery item should look like
class Category {
  const Category(
    this.title,
    this.color,
  );

  final String title;
  final Color color;
}
