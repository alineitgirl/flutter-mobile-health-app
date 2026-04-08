import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  // Mock recipes data
  final List<Map<String, dynamic>> recipes = [
    {
      'id': '1',
      'name': 'Куриное филе с рисом',
      'emoji': '🍗',
      'prepTime': '20 мин',
      'servings': 2,
      'calories': '450 ккал',
      'products': ['Куриное филе', 'Коричневый рис'],
      'description': 'Простой и полезный рецепт для спортсменов',
    },
    {
      'id': '2',
      'name': 'Лосось с овощами',
      'emoji': '🐟',
      'prepTime': '30 мин',
      'servings': 2,
      'calories': '520 ккал',
      'products': ['Свежий лосось', 'Брокколи'],
      'description': 'Богат белками и омега-3 жирными кислотами',
    },
    {
      'id': '3',
      'name': 'Салат из свежих овощей',
      'emoji': '🥗',
      'prepTime': '10 мин',
      'servings': 3,
      'calories': '150 ккал',
      'products': ['Брокколи'],
      'description': 'Легкий и освежающий салат для здорового питания',
    },
  ];

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
            title: const Text(
              'Мои рецепты',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
            centerTitle: false,
            collapsedHeight: 80,
            expandedHeight: 120,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recipe = recipes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                            recipe: recipe,
                          ),
                        ),
                      );
                    },
                    child: _buildRecipeCard(recipe),
                  );
                },
                childCount: recipes.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to recipe builder
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Внскоре появится создание собственных рецептов'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add),
        label: const Text(
          'Новый рецепт',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.3),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['emoji'] as String,
                  style: const TextStyle(fontSize: 44),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withAlpha(128),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoBadge(
                            Icons.schedule_outlined,
                            recipe['prepTime'] as String,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoBadge(
                            Icons.people_outline,
                            '${recipe['servings']} порц.',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoBadge(
                            Icons.local_fire_department_outlined,
                            recipe['calories'] as String,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var product in recipe['products'] as List<String>)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withAlpha(50),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          product,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2E7D32),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.black.withAlpha(128),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black.withAlpha(128),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
