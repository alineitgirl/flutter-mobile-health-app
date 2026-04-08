import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_match/domain/providers/providers.dart';
import '../../data/models/product.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;
  
  const ProductDetailScreen({super.key, required this.product});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    
    bool isAllowed = true;
    List<String> conflicts=[];
    
    if (profile != null && profile.restrictions.isNotEmpty) {
      final ingredientsLower = product.ingredients.toLowerCase();
      for (var restriction in profile.restrictions) {
        if (ingredientsLower.contains(restriction.toLowerCase())) {
          isAllowed = false;
          conflicts.add(restriction);
        }
      }
    }
    
    final statusColor = isAllowed ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final statusText = isAllowed ? 'Можно' : 'Нельзя';
    
    return Scaffold(
      appBar: AppBar(title: Text(product.name), backgroundColor: statusColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null)
              Center(
                child: Image.network(product.imageUrl!, height: 200),
              ),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Категория: ${product.category}'),
            Text('Калории: ${product.calories} ккал'),
            Text('БЖУ: ${product.protein} / ${product.fat} / ${product.carbs}'),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: statusColor, size: 32),
                  const SizedBox(width: 12),
                  Text(statusText,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
            ),
            
            if  (conflicts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Конфликтующие ингредиенты', style: TextStyle(fontWeight: FontWeight.bold)),
              ...conflicts.map((c) => Text('• $c', style: const TextStyle(color: Colors.red))),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(favoritesProvider.notifier).toggleFavorite(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Добавлено в Избранное')),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('В избранное'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(shoppingListProvider.notifier).addToShoppingList(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Добавлено в список покупок')),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('В покупки'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Состав: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(product.ingredients),
          ],
        ),
      ),
    );
  }
}