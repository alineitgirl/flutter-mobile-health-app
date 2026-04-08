import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/providers.dart';
import 'profile_form_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final isEditing = ref.watch(_isEditingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: userProfile != null && !isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => ref.read(_isEditingProvider.notifier).state = true,
                ),
              ]
            : null,
      ),
      body: userProfile == null
          ? const Center(
              child: Text('Профиль не настроен. Пройдите онбординг.'),
            )
          : isEditing
              ? ProfileFormWidget(
                  initialProfile: userProfile,
                  onSave: (profile) {
                    ref.read(userProfileProvider.notifier).saveProfile(profile);
                    ref.read(_isEditingProvider.notifier).state = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Профиль успешно сохранён'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 32, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userProfile.name,
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${userProfile.age} лет',
                                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildInfoItem('Рост', '${userProfile.height} см'),
                                  _buildInfoItem('Вес', '${userProfile.weight} кг'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (userProfile.restrictions.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Диетические ограничения:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: userProfile.restrictions
                                  .map((r) => Chip(label: Text(r)))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      if (userProfile.goals.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Цели:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: userProfile.goals
                                  .map((g) => Chip(label: Text(g)))
                                  .toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

final _isEditingProvider = StateProvider<bool>((ref) => false);