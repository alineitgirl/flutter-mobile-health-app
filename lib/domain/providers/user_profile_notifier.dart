import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_profile.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile.initial()) {
    _loadFromHive();
  }

  Future<void> _loadFromHive() async {
    final box = Hive.box<UserProfile>('userProfile');
    final savedProfile = box.get('profile');
    if (savedProfile != null) {
      state = savedProfile;
    }
  }

  void updateProfile(UserProfile newProfile) {
    state = newProfile;
    Hive.box<UserProfile>('userProfile').put('profile', newProfile);
  }

  void updateRestrictions(List<String> restrictions) {
    state = state.copyWith(restrictions: restrictions);
    Hive.box<UserProfile>('userProfile').put('profile', state);
  }

  void updateGoals(List<String> goals) {
    state = state.copyWith(goals: goals);
    Hive.box<UserProfile>('userProfile').put('profile', state);
  }

  void resetProfile() {
    state = UserProfile.initial();
    Hive.box<UserProfile>('userProfile').put('profile', state);
  }
}

final userProfileProvider =
StateNotifierProvider<UserProfileNotifier, UserProfile>(
      (ref) => UserProfileNotifier(),
);