import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String ingredients;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final double calories;

  @HiveField(5)
  final double protein;

  @HiveField(6)
  final double fat;

  @HiveField(7)
  final double carbs;

  @HiveField(8)
  final String? imageUrl;

  @HiveField(9)
  final String? barcode;

  Product({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.category,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.imageUrl,
    this.barcode,
  });
}

