import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class ProductRepository {
  static const String _boxName = 'products';
  final String _apiBase = 'https://world.openfoodfacts.org/api/v2';

  Future<Product?> getProduct(String query) async {
    final box = await Hive.openBox<Product>(_boxName);

    final cached = box.values.where((p) =>
    p.barcode == query || p.name.toLowerCase().contains(query.toLowerCase())
    ).firstOrNull;

    if (cached != null) return cached;

    final url = Uri.parse('$_apiBase/product/$query.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['product'];
      if (data == null) return null;

      final product = Product(
        id: data['code'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: data['product_name'] ?? 'Без названия',
        ingredients: data['ingredients_text'] ?? '',
        category: data['categories'] ?? 'Другое',
        calories: double.tryParse(data['nutriments']?['energy_100g']?.toString() ?? '0') ?? 0,
        protein: double.tryParse(data['nutriments']?['proteins_100g']?.toString() ?? '0') ?? 0,
        fat: double.tryParse(data['nutriments']?['fat_100g']?.toString() ?? '0') ?? 0,
        carbs: double.tryParse(data['nutriments']?['carbohydrates_100g']?.toString() ?? '0') ?? 0,
        imageUrl: data['image_url'],
        barcode: data['code'],
      );

      await box.put(product.id, product);
      return product;
    }
    return null;
  }

  Future<List<Product>> searchProducts(String query) async {
    // Пока простой поиск по кэшу + API
    final box = await Hive.openBox<Product>(_boxName);
    final cached = box.values.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (cached.isNotEmpty) return cached;

    // Если в кэше ничего нет — делаем запрос по названию
    final url = Uri.parse('$_apiBase/search?search_terms=$query&search_simple=1&json=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final productsJson = json.decode(response.body)['products'] as List;
      final products = productsJson.map((json) => Product(
        id: json['code'],
        name: json['product_name'] ?? '',
        ingredients: json['ingredients_text'] ?? '',
        category: json['categories'] ?? '',
        calories: double.tryParse(json['nutriments']?['energy_100g']?.toString() ?? '0') ?? 0,
        protein: double.tryParse(json['nutriments']?['proteins_100g']?.toString() ?? '0') ?? 0,
        fat: double.tryParse(json['nutriments']?['fat_100g']?.toString() ?? '0') ?? 0,
        carbs: double.tryParse(json['nutriments']?['carbohydrates_100g']?.toString() ?? '0') ?? 0,
        imageUrl: json['image_url'],
        barcode: json['code'],
      )).toList();

      // Сохраняем всё в кэш
      for (var p in products) {
        await box.put(p.id, p);
      }
      return products;
    }
    return [];
  }
}