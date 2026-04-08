import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _showProductDetail = false;
  Map<String, dynamic>? _selectedProduct;

  void _showProductDetailModal(Map<String, dynamic> product) {
    setState(() {
      _selectedProduct = product;
      _showProductDetail = true;
    });
  }

  void _hideProductDetailModal() {
    setState(() {
      _showProductDetail = false;
      _selectedProduct = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    // Mock product data based on recipe
    final Map<String, Map<String, dynamic>> productsData = {
      'Куриное филе': {
        'name': 'Куриное филе',
        'emoji': '🍗',
        'calories': '165 ккал/100г',
        'proteins': '31 г',
        'fats': '3.6 г',
        'carbs': '0 г',
        'description': 'Отличный источник белка для спортсменов',
      },
      'Коричневый рис': {
        'name': 'Коричневый рис',
        'emoji': '🍚',
        'calories': '111 ккал/100г',
        'proteins': '3 г',
        'fats': '0.9 г',
        'carbs': '23 г',
        'description': 'Богат углеводами и клетчаткой',
      },
      'Свежий лосось': {
        'name': 'Свежий лосось',
        'emoji': '🐟',
        'calories': '206 ккал/100г',
        'proteins': '22 г',
        'fats': '13 г',
        'carbs': '0 г',
        'description': 'Великолепный источник омега-3',
      },
      'Брокколи': {
        'name': 'Брокколи',
        'emoji': '🥦',
        'calories': '34 ккал/100г',
        'proteins': '2.8 г',
        'fats': '0.4 г',
        'carbs': '7 г',
        'description': 'Низкокалорийный овощ, богат витаминами',
      },
    };

    final productsList = (recipe['products'] as List<String>)
        .map((name) => productsData[name] ?? {})
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
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
                          recipe['emoji'] as String,
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['name'] as String,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recipe['description'] as String,
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

                    // Info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard(
                          Icons.schedule_outlined,
                          recipe['prepTime'] as String,
                          'Время',
                        ),
                        _buildInfoCard(
                          Icons.people_outline,
                          '${recipe['servings']}',
                          'Порций',
                        ),
                        _buildInfoCard(
                          Icons.local_fire_department_outlined,
                          recipe['calories'] as String,
                          'Калории',
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Products section
                    Text(
                      'Ингредиенты',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var product in productsList)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _showProductDetailModal(product),
                          child: Container(
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
                                  style: const TextStyle(fontSize: 36),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
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
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.black.withAlpha(128),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Instructions section
                    Text(
                      'Способ приготовления',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '1. Промойте ингредиенты под холодной водой\n\n'
                        '2. Нарежьте куриное филе на кусочки\n\n'
                        '3. Отварите рис согласно инструкции на упаковке\n\n'
                        '4. Обжарьте куриное филе на сковороде\n\n'
                        '5. Смешайте куриное филе с рисом\n\n'
                        '6. Подавайте горячим',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withAlpha(180),
                          letterSpacing: -0.2,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Add to favorites button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${recipe['name']} добавлен в избранное',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withAlpha(40),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Добавить в избранное',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
          if (_showProductDetail && _selectedProduct != null)
            _buildProductDetailModal(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black.withAlpha(128),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailModal() {
    final product = _selectedProduct;
    if (product == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _hideProductDetailModal,
      child: Container(
        color: Colors.black.withAlpha(120),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Подробно о продукте',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: -0.4,
                            ),
                          ),
                          GestureDetector(
                            onTap: _hideProductDetailModal,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product header
                          Row(
                            children: [
                              Text(
                                product['emoji'] as String,
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product['description'] as String,
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

                          // Nutrition section
                          Text(
                            'Пищевая ценность (на 100г)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withAlpha(180),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailedInfoRow(
                            'Калории',
                            product['calories'] as String,
                            Icons.local_fire_department_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailedInfoRow(
                            'Белки',
                            product['proteins'] as String,
                            Icons.fitness_center_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailedInfoRow(
                            'Жиры',
                            product['fats'] as String,
                            Icons.opacity_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailedInfoRow(
                            'Углеводы',
                            product['carbs'] as String,
                            Icons.grain_outlined,
                          ),
                          const SizedBox(height: 32),

                          // Close button
                          GestureDetector(
                            onTap: _hideProductDetailModal,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Закрыть',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedInfoRow(
      String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
