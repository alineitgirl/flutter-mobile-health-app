import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_boxes.dart';
import '../../data/models/product.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/product_repository.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
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

final searchResultsProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.searchProducts(query);
});