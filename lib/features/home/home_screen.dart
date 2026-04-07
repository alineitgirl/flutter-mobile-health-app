import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../catalog/catalog_screen.dart';
import '../profile/profile_screen.dart';
import '../favorites/favorites_screen.dart';
import '../shopping_list/shopping_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Главная', style: TextStyle(fontSize: 32))),     // Главная
    const CatalogScreen(),                                                     // Каталог / Поиск
    const Center(child: Text('Сканер', style: TextStyle(fontSize: 32))),       // Сканер (заглушка)
    const Center(child: Text('Рецепты', style: TextStyle(fontSize: 32))),      // Рецепты (заглушка)
    const ProfileScreen(),                                                     // Профиль
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFood'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Каталог'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Сканер'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Рецепты'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}