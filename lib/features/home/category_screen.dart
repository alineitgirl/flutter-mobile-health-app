import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class _Product {
  final String name;
  final String emoji;
  final String calories;
  final String imageUrl;
  final double? nutriScore;
  final String? nutriScoreGrade;

  const _Product({
    required this.name,
    required this.emoji,
    required this.calories,
    required this.imageUrl,
    this.nutriScore,
    this.nutriScoreGrade,
  });
}

const _categoryConfig = {
  'Овощи':   (query: 'vegetable',  emoji: '🥦'),
  'Фрукты':  (query: 'fruit',      emoji: '🍎'),
  'Белки':   (query: 'chicken protein meat', emoji: '🍗'),
  'Ягоды':   (query: 'berry',      emoji: '🍓'),
  'Зерновые':(query: 'grain cereal', emoji: '🌾'),
  'Молочное':(query: 'dairy milk', emoji: '🥛'),
};

const _emojiMap = {
  'apple': '🍎', 'banana': '🍌', 'orange': '🍊', 'lemon': '🍋',
  'grape': '🍇', 'strawberry': '🍓', 'cherry': '🍒', 'peach': '🍑',
  'pear': '🍐', 'mango': '🥭', 'pineapple': '🍍', 'watermelon': '🍉',
  'blueberry': '🫐', 'raspberry': '🫐', 'blackberry': '🫐',
  'broccoli': '🥦', 'carrot': '🥕', 'tomato': '🍅', 'cucumber': '🥒',
  'spinach': '🥬', 'lettuce': '🥬', 'cabbage': '🥬', 'onion': '🧅',
  'garlic': '🧄', 'potato': '🥔', 'pepper': '🫑', 'corn': '🌽',
  'mushroom': '🍄', 'avocado': '🥑',
  'chicken': '🍗', 'beef': '🥩', 'pork': '🥩', 'fish': '🐟',
  'salmon': '🐟', 'tuna': '🐟', 'egg': '🥚', 'shrimp': '🍤',
  'milk': '🥛', 'cheese': '🧀', 'yogurt': '🥛', 'butter': '🧈',
  'bread': '🍞', 'rice': '🍚', 'oat': '🌾', 'wheat': '🌾',
  'pasta': '🍝', 'cereal': '🌾',
  'chocolate': '🍫', 'coffee': '☕', 'tea': '🍵',
  'water': '💧', 'juice': '🧃',
};

String _emojiForName(String name, String fallback) {
  final lower = name.toLowerCase();
  for (final entry in _emojiMap.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return fallback;
}

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
  List<_Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _loading = true; _error = null; });

    try {
      final config = _categoryConfig[widget.categoryTitle];
      final query = config?.query ?? widget.categoryTitle;
      final fallbackEmoji = config?.emoji ?? widget.emoji;
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl'
        '?search_terms=${Uri.encodeComponent(query)}'
        '&search_simple=1'
        '&action=process'
        '&json=1'
        '&page_size=20'
        '&fields=product_name,nutriments,nutriscore_grade,image_front_small_url',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawList = (data['products'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      final products = rawList
          .where((p) {
            final name = (p['product_name'] as String?)?.trim() ?? '';
            return name.isNotEmpty;
          })
          .map((p) {
            final name = (p['product_name'] as String).trim();
            final kcal = p['nutriments']?['energy-kcal_100g'];
            final calories = kcal != null
                ? '${(kcal as num).toInt()} ккал/100г'
                : '— ккал/100г';
            final grade =
                (p['nutriscore_grade'] as String?)?.toUpperCase();
            final score = _nutriGradeToScore(grade);
            final imageUrl =
                (p['image_front_small_url'] as String?) ?? '';

            return _Product(
              name: name,
              emoji: _emojiForName(name, fallbackEmoji),
              calories: calories,
              imageUrl: imageUrl,
              nutriScore: score,
              nutriScoreGrade: grade,
            );
          })
          .take(15)
          .toList();

      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить данные.\nПроверьте интернет-соединение.';
        _loading = false;
      });
    }
  }

  double? _nutriGradeToScore(String? grade) {
    switch (grade) {
      case 'A': return 5.0;
      case 'B': return 4.0;
      case 'C': return 3.0;
      case 'D': return 2.0;
      case 'E': return 1.0;
      default:  return null;
    }
  }

  Color _nutriGradeColor(String? grade) {
    switch (grade) {
      case 'A': return const Color(0xFF1B8A42);
      case 'B': return const Color(0xFF56AA1C);
      case 'C': return const Color(0xFFEFAC00);
      case 'D': return const Color(0xFFE07420);
      case 'E': return const Color(0xFFDA1C22);
      default:  return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black, size: 18),
              ),
            ),
            actions: [
              if (!_loading)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: _loadProducts,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          color: Colors.black, size: 20),
                    ),
                  ),
                ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(widget.emoji,
                        style: const TextStyle(fontSize: 48)),
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
                            _loading
                                ? 'Загружаем...'
                                : _error != null
                                    ? 'Ошибка загрузки'
                                    : '${_products.length} продуктов',
                            style: TextStyle(
                              fontSize: 14,
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

          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text('Загружаем продукты...',
                        style: TextStyle(
                            fontSize: 15, color: Colors.black54)),
                  ],
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 52, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withAlpha(140),
                            height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _loadProducts,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text('Попробовать снова',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_products.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.emoji,
                        style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 16),
                    Text(
                      'Продукты не найдены',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black.withAlpha(140)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList.separated(
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _ProductTile(product: _products[index],
                        gradeColor: _nutriGradeColor),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final _Product product;
  final Color Function(String?) gradeColor;

  const _ProductTile({
    required this.product,
    required this.gradeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: 48, height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _EmojiBox(product.emoji),
                  )
                : _EmojiBox(product.emoji),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.calories,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withAlpha(128),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          if (product.nutriScoreGrade != null)
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: gradeColor(product.nutriScoreGrade),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  product.nutriScoreGrade!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmojiBox extends StatelessWidget {
  final String emoji;
  const _EmojiBox(this.emoji);

  @override
  Widget build(BuildContext context) => Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 26)),
        ),
      );
}