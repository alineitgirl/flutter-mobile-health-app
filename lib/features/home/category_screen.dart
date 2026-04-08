import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryTitle;
  final String emoji;
  final String categoryCount;

  const CategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.emoji,
    required this.categoryCount,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Mock products for the category
  late final List<Map<String, dynamic>> products;

  @override
  void initState() {
    super.initState();
    // Generate mock products based on category
    products = _generateProductsForCategory();
  }

  List<Map<String, dynamic>> _generateProductsForCategory() {
    final categoryProducts = {
      'Овощи': [
        {
          'name': 'Брокколи',
          'emoji': '🥦',
          'calories': '34 ккал/100г',
          'rating': 4.9,
        },
        {
          'name': 'Морковь',
          'emoji': '🥕',
          'calories': '41 ккал/100г',
          'rating': 4.7,
        },
        {
          'name': 'Помидоры',
          'emoji': '🍅',
          'calories': '18 ккал/100г',
          'rating': 4.8,
        },
        {
          'name': 'Огурцы',
          'emoji': '🥒',
          'calories': '16 ккал/100г',
          'rating': 4.6,
        },
        {
          'name': 'Капуста',
          'emoji': '🥬',
          'calories': '25 ккал/100г',
          'rating': 4.5,
        },
      ],
      'Фрукты': [
        {
          'name': 'Яблоки',
          'emoji': '🍎',
          'calories': '52 ккал/100г',
          'rating': 4.8,
        },
        {
          'name': 'Бананы',
          'emoji': '🍌',
          'calories': '89 ккал/100г',
          'rating': 4.7,
        },
        {
          'name': 'Апельсины',
          'emoji': '🍊',
          'calories': '47 ккал/100г',
          'rating': 4.9,
        },
        {
          'name': 'Груши',
          'emoji': '🍐',
          'calories': '57 ккал/100г',
          'rating': 4.6,
        },
      ],
      'Белки': [
        {
          'name': 'Куриное филе',
          'emoji': '🍗',
          'calories': '165 ккал/100г',
          'rating': 4.8,
        },
        {
          'name': 'Яйца',
          'emoji': '🥚',
          'calories': '155 ккал/100г',
          'rating': 4.7,
        },
        {
          'name': 'Говядина',
          'emoji': '🥩',
          'calories': '250 ккал/100г',
          'rating': 4.9,
        },
        {
          'name': 'Рыба',
          'emoji': '🐟',
          'calories': '200 ккал/100г',
          'rating': 4.8,
        },
      ],
      'Ягоды': [
        {
          'name': 'Черника',
          'emoji': '🫐',
          'calories': '57 ккал/100г',
          'rating': 4.9,
        },
        {
          'name': 'Клубника',
          'emoji': '🍓',
          'calories': '32 ккал/100г',
          'rating': 4.8,
        },
        {
          'name': 'Малина',
          'emoji': '🫐',
          'calories': '52 ккал/100г',
          'rating': 4.7,
        },
      ],
    };

    return categoryProducts[widget.categoryTitle] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                // Header
                Row(
                  children: [
                    Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryTitle,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.categoryCount,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black.withAlpha(128),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        product['emoji'] as String,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] as String,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product['calories'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withAlpha(128),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: const Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (product['rating']).toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: const SizedBox(height: 32),
            ),
          ),
        ],
      ),
    );
  }
}
