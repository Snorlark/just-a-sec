import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String firstName;

  @HiveField(2)
  late String lastName;

  @HiveField(3)
  String? profilePicturePath;
  // Local file path to profile picture (saved via path_provider)

  @HiveField(4)
  DateTime? profilePictureDate;
  // When picture was added/updated

  UserModel({
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profilePicturePath,
    this.profilePictureDate,
  });
}
