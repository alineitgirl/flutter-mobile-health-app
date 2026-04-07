import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile.dart';
import '../../domain/providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  final List<String> _selectedRestrictions = [];
  String? _selectedGoal;

  final List<String> _restrictionsList = [
    'Глютен', 'Орехи', 'Лактоза', 'Молоко', 'Яйца', 'Соя', 'Морепродукты',
    'Веган', 'Вегетарианец', 'Без сахара', 'Кето'
  ];

  final List<Map<String, String>> _goals = [
    {'key': 'weight_loss', 'label': 'Похудение'},
    {'key': 'muscle_gain', 'label': 'Набор массы'},
    {'key': 'maintenance', 'label': 'Поддержание формы'},
  ];

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Сохраняем профиль и переходим дальше
      final profile = UserProfile(
        restrictions: _selectedRestrictions,
        goal: _selectedGoal,
      );
      ref.read(userProfileProvider.notifier).saveProfile(profile);
      Navigator.pushReplacementNamed(context, '/home'); // позже заменим
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartFood — настройка профиля')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Прогресс
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: Colors.grey[300],
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 32),

            // Шаг 1
            if (_currentStep == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Какие продукты вам нельзя?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _restrictionsList.map((item) {
                      final isSelected = _selectedRestrictions.contains(item);
                      return FilterChip(
                        label: Text(item),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedRestrictions.add(item);
                            } else {
                              _selectedRestrictions.remove(item);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),

            // Шаг 2
            if (_currentStep == 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Какая у вас цель питания?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ..._goals.map((goal) => RadioListTile<String>(
                    title: Text(goal['label']!),
                    value: goal['key']!,
                    groupValue: _selectedGoal,
                    onChanged: (value) => setState(() => _selectedGoal = value),
                  )),
                ],
              ),

            // Шаг 3 (можно добавить возраст/пол позже)
            if (_currentStep == 2)
              const Center(
                child: Text(
                  'Отлично!\nТеперь мы знаем ваши ограничения и цель.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
              ),

            const Spacer(),

            // Кнопки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text('Назад'),
                  ),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(_currentStep == 2 ? 'Завершить' : 'Далее'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}