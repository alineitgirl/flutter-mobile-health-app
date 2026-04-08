import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';

class ProfileFormWidget extends StatefulWidget {
  final UserProfile? initialProfile;
  final Function(UserProfile) onSave;
  final bool isOnboarding;

  const ProfileFormWidget({
    super.key,
    this.initialProfile,
    required this.onSave,
    this.isOnboarding = false,
  });

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late List<String> _restrictions;
  late List<String> _goals;

  final List<String> allRestrictions = ['Вегетарианство', 'Веганство', 'Без глютена', 'Без лактозы', 'Кошерное', 'Халяль'];
  final List<String> allGoals = ['Похудение', 'Набор мышечной массы', 'Улучшение здоровья', 'Спортивная подготовка'];

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile ?? UserProfile.initial();
    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: profile.age.toString());
    _heightController = TextEditingController(text: profile.height.toString());
    _weightController = TextEditingController(text: profile.weight.toString());
    _restrictions = List.from(profile.restrictions);
    _goals = List.from(profile.goals);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите имя')),
      );
      return;
    }

    final profile = UserProfile(
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? 25,
      height: double.tryParse(_heightController.text) ?? 170.0,
      weight: double.tryParse(_weightController.text) ?? 70.0,
      restrictions: _restrictions,
      goals: _goals,
    );

    widget.onSave(profile);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Имя',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Возраст',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Рост (см)',
                    prefixIcon: Icon(Icons.height),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Вес (кг)',
              prefixIcon: Icon(Icons.monitor_weight),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Диетические ограничения:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: allRestrictions.map((restriction) {
              final isSelected = _restrictions.contains(restriction);
              return FilterChip(
                selected: isSelected,
                label: Text(restriction),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _restrictions.add(restriction);
                    } else {
                      _restrictions.remove(restriction);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ваши цели:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: allGoals.map((goal) {
              final isSelected = _goals.contains(goal);
              return FilterChip(
                selected: isSelected,
                label: Text(goal),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _goals.add(goal);
                    } else {
                      _goals.remove(goal);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.isOnboarding ? 'Завершить' : 'Сохранить изменения'),
            ),
          ),
        ],
      ),
    );
  }
}