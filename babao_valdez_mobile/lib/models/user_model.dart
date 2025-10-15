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

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String age;
  final String gender;
  final String contactNumber;
  final String email;
  final String username;
  final String address;
  final bool isActive;
  final String type;

  User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.contactNumber,
    required this.email,
    required this.username,
    required this.address,
    required this.isActive,
    required this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      contactNumber: json['contactNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      isActive: json['isActive'] == true,
      type: json['type']?.toString() ?? '',
    );
  }
}
