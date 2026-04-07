import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}