import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_profile.dart';
import '../../domain/providers/providers.dart';
import '../home/home_screen.dart';
import '../profile/profile_form_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Добро пожаловать в SmartFood!',
      'description': 'Ваше персональное приложение для здорового питания.',
    },
    {
      'title': 'Ищите продукты',
      'description': 'Используйте каталог для поиска полезных продуктов.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToProfileForm();
    }
  }

  void _goToProfileForm() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding(UserProfile profile) async {
    await ref.read(userProfileProvider.notifier).saveProfile(profile);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final page in _pages)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    page['title']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    page['description']!,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          Scaffold(
            appBar: AppBar(
              title: const Text('Немного о вас'),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
            ),
            body: ProfileFormWidget(
              onSave: _completeOnboarding,
              isOnboarding: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _currentPage < _pages.length
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_currentPage + 1}/3'),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Далее'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}