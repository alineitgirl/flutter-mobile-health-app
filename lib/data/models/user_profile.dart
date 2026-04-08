import 'package:hive_flutter/hive_flutter.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  double height;

  @HiveField(3)
  double weight;

  @HiveField(4)
  List<String> restrictions;

  @HiveField(5)
  List<String> goals;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.restrictions,
    required this.goals,
  });

  factory UserProfile.initial() => UserProfile(
    name: '',
    age: 25,
    height: 170.0,
    weight: 70.0,
    restrictions: [],
    goals: [],
  );

  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    double? weight,
    List<String>? restrictions,
    List<String>? goals,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      restrictions: restrictions ?? List<String>.from(this.restrictions),
      goals: goals ?? List<String>.from(this.goals),
    );
  }
}

extension UserProfileExtensions on UserProfile {
  static const List<String> allPossibleRestrictions = [
    'Арахис',
    'Глютен',
    'Молоко',
    'Яйца',
    'Соевый',
    'Рыба',
    'Морепродукты',
    'Орехи',
    'Сахар',
    'Лактоза',
    'Фруктоза',
  ];

  static const List<String> allPossibleGoals = [
    'Похудение',
    'Набор массы',
    'Поддержание веса',
    'Безлактозное питание',
    'Низкоуглеводное',
    'Вегетарианское',
    'Веганское',
  ];
}