import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_match/domain/providers/providers.dart';
import 'package:food_match/features/home/home_screen.dart';
import 'package:food_match/features/onboarding/onboarding_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/product.dart';
import 'data/models/user_profile.dart';
import 'core/constants/hive_boxes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  await Hive.openBox<Product>(HiveBoxes.products);
  await Hive.openBox<UserProfile>(HiveBoxes.profile);
  await Hive.openBox<String>(HiveBoxes.favorites);
  await Hive.openBox<String>(HiveBoxes.shoppingList);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    return MaterialApp(
      title: 'SmartFood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: onboardingCompleted ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}