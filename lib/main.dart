import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_match/domain/providers/providers.dart';
import 'package:food_match/features/auth/auth_screen.dart';
import 'package:food_match/features/home/home_screen.dart';
import 'package:food_match/features/onboarding/onboarding_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/product.dart';
import 'data/models/user_profile.dart';
import 'core/constants/hive_boxes.dart';
import 'package:food_match/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  await Hive.openBox<Product>(HiveBoxes.products);
  await Hive.openBox<UserProfile>(HiveBoxes.profile);
  await Hive.openBox<Product>(HiveBoxes.favorites);     
  await Hive.openBox<Product>(HiveBoxes.shoppingList); 

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SmartFood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const _RootNavigator(),
    );
  }
}


class _RootNavigator extends ConsumerWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(onboardingCompletedProvider);
    final authState = ref.watch(authStateProvider);

   
    if (!onboardingDone) {
      return const OnboardingScreen();
    }

    return authState.when(
      loading: () => const _SplashScreen(),

      error: (e, _) => Scaffold(
        body: Center(
          child: Text('Ошибка Firebase: $e'),
        ),
      ),

      data: (User? user) {
        if (user == null) {
          return const AuthScreen();
        }
        return const HomeScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D32),
          strokeWidth: 3,
        ),
      ),
    );
  }
}