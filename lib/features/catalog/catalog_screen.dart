import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartfood/domain/providers/providers.dart';
import '../product_detail/product_detail_screen.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider(_searchController.text));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Поиск продукта или штрих-кода',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => setState(() => {}),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: searchResults.when(
              data: (products) => products.isEmpty
                  ? const Center(child: Text('Ничего не найдено'))
                  : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: product.imageUrl != null
                        ? Image.network(product.imageUrl!, width: 50, height: 50, fit: BoxFit.cover,)
                        : const Icon(Icons.fastfood, size: 50),
                    title: Text(product.name),
                    subtitle: Text('${product.calories} ккал • ${product.category}'),
                    onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product),
                    ),
                  ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Ошибка поиска')),
            ),
          ),
        ],
      )
    );
  }
}