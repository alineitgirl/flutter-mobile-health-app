import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_match/domain/providers/providers.dart';
import 'package:food_match/features/product_detail/product_detail_screen.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return ListTile(
          leading: product.imageUrl != null
              ? Image.network(product.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.favorite),
          title: Text(product.name),
          subtitle: Text('${product.calories} ккал'),
          onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        ),
        );
      },
    );
  }
}