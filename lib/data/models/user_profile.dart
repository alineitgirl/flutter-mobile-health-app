import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  int? age;

  @HiveField(2)
  String? sex;

  @HiveField(3)
  double? weight;

  @HiveField(4)
  double? height;

  @HiveField(5)
  String? activityLevel;

  @HiveField(6)
  String? goal;

  @HiveField(7)
  List<String> restrictions;

  UserProfile({
    this.name,
    this.age,
    this.sex,
    this.weight,
    this.height,
    this.activityLevel,
    this.goal,
    List<String>? restrictions,
  }) : restrictions = restrictions ?? [];
}