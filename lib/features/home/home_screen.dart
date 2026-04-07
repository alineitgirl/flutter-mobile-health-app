import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_match/domain/providers/providers.dart';

import '../catalog/catalog_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Главная', style: TextStyle(fontSize: 32))),
    const CatalogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);

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
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Каталог'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          ],
      )
    );
  }
}