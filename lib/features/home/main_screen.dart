import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/providers.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(userProfile),

          _buildQuickActions(),

          _buildFeaturedCategories(),

          _buildHealthTips(),

          _buildRecommendations(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(userProfile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Привет',
            style: TextStyle(
              color: Colors.black38,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userProfile?.name ?? 'Пользователь',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 42,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          _buildHealthCard(
            icon: Icons.water_drop_outlined,
            title: 'Ежедневная гидратация',
            subtitle: '8 стаканов воды',
            progress: 0.65,
            color: const Color(0xFF5AC8FA),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required Color color,
  }) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'Каталог',
        'color': const Color(0xFF2E7D32),
      },
      {
        'icon': Icons.heart_broken,
        'title': 'Избранное',
        'color': const Color(0xFFE53935),
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'Покупки',
        'color': const Color(0xFF5AC8FA),
      },
      {
        'icon': Icons.fastfood_outlined,
        'title': 'Рецепты',
        'color': const Color(0xFFFFA500),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final action = actions[index];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (action['color'] as Color).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          action['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCategories() {
    final categories = [
      {
        'title': 'Овощи',
        'emoji': '🥬',
        'count': '245 товаров',
      },
      {
        'title': 'Фрукты',
        'emoji': '🍎',
        'count': '156 товаров',
      },
      {
        'title': 'Белки',
        'emoji': '🥚',
        'count': '189 товаров',
      },
      {
        'title': 'Ягоды',
        'emoji': '🫐',
        'count': '98 товаров',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Категории',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {},
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
                        category['emoji'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['title'] as String,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['count'] as String,
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Рекомендации здоровья',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81C784).withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF81C784),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Пейте воду регулярно',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Адекватное потребление воды помогает поддерживать правильный обмен веществ и улучшает пищеварение.',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    letterSpacing: -0.2,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Узнать больше',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = [
      {
        'name': 'Куриное филе',
        'calories': '165 ккал/100г',
        'emoji': '🍗',
        'rating': 4.8,
      },
      {
        'name': 'Коричневый рис',
        'calories': '111 ккал/100г',
        'emoji': '🍚',
        'rating': 4.6,
      },
      {
        'name': 'Брокколи',
        'calories': '34 ккал/100г',
        'emoji': '🥦',
        'rating': 4.9,
      },
      {
        'name': 'Свежий лосось',
        'calories': '206 ккал/100г',
        'emoji': '🐟',
        'rating': 4.7,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Популярные продукты',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = recommendations[index];
              return GestureDetector(
                onTap: () {},
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
                        item['emoji'] as String,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['calories'] as String,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: const Color(0xFFFFC107),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (item['rating']).toString(),
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
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}