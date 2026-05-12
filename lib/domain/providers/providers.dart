import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/hive_boxes.dart';
import '../../data/models/product.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/product_repository.dart';
 
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
 
final authProvider = Provider<AuthNotifier>((ref) => AuthNotifier());
 
class AuthNotifier {
  final _auth = FirebaseAuth.instance;
 
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
 

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
 
  Future<void> signOut() async {
    await _auth.signOut();
  }
 
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
 
 
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});
 
class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _loadProfile();
  }
 
  final _box = Hive.box<UserProfile>(HiveBoxes.profile);
 
  void _loadProfile() {
    if (_box.isNotEmpty) {
      state = _box.getAt(0);
    }
  }
 
  Future<void> saveProfile(UserProfile profile) async {
    await _box.clear();
    await _box.add(profile);
    state = profile;
  }
 
  void updateRestrictions(List<String> restrictions) {
    if (state != null) {
      state!.restrictions = restrictions;
      saveProfile(state!);
    }
  }
}
 
 
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});
 
final searchResultsProvider =
    FutureProvider.family<List<Product>, String>((ref, query) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.searchProducts(query);
});
 
 
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Product>>((ref) {
  return FavoritesNotifier();
});
 
class FavoritesNotifier extends StateNotifier<List<Product>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }
 
  final _box = Hive.box<Product>(HiveBoxes.favorites);
 
  void _loadFavorites() {
    state = _box.values.toList();
  }
 
  Future<void> toggleFavorite(Product product) async {
    if (state.any((p) => p.id == product.id)) {
      await _box.delete(product.id);
    } else {
      await _box.put(product.id, product);
    }
    _loadFavorites();
  }
}
 
final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<Product>>((ref) {
  return ShoppingListNotifier();
});
 
class ShoppingListNotifier extends StateNotifier<List<Product>> {
  ShoppingListNotifier() : super([]) {
    _loadShoppingList();
  }
 
  final _box = Hive.box<Product>(HiveBoxes.shoppingList);
 
  void _loadShoppingList() {
    state = _box.values.toList();
  }
 
  Future<void> addToShoppingList(Product product) async {
    if (!state.any((p) => p.id == product.id)) {
      await _box.put(product.id, product);
      _loadShoppingList();
    }
  }
 
  Future<void> removeFromShoppingList(String id) async {
    await _box.delete(id);
    _loadShoppingList();
  }
}

 
final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});
 
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _checkOnboardingStatus();
  }
 
  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('onboarding_completed') ?? false;
  }
 
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    state = true;
  }
 
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', false);
    state = false;
  }
}
 