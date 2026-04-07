import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_match/domain/providers/providers.dart';
import 'package:food_match/features/product_detail/product_detail_screen.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(shoppingListProvider);

    return ListView.builder(
      itemCount: shoppingList.length,
      itemBuilder: (context, index) {
        final product = shoppingList[index];
        return ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: Text(product.name),
          subtitle: Text('${product.calories} ккал'),
          onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
          ),
          trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => ref.read(shoppingListProvider.notifier).removeFromShoppingList(product.id),
        ),
        );
      }
    );
  }
}