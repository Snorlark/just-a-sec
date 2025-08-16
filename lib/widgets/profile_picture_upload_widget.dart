import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_model.dart';

class ProfilePictureUploadWidget extends StatefulWidget {
  final Function(String path, DateTime date) onImagePicked;

  const ProfilePictureUploadWidget({super.key, required this.onImagePicked});

  @override
  State<ProfilePictureUploadWidget> createState() =>
      _ProfilePictureUploadState();
}

class _ProfilePictureUploadState extends State<ProfilePictureUploadWidget> {
  File? _imageFile;
  late Box<UserModel> _box;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    _box = await Hive.openBox<UserModel>('userBox');

    if (_box.isNotEmpty) {
      final user = _box.getAt(0);
      if (user != null &&
          user.profilePicturePath != null &&
          File(user.profilePicturePath!).existsSync()) {
        setState(() {
          _imageFile = File(user.profilePicturePath!);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedImage = await File(
      pickedFile.path,
    ).copy('${appDir.path}/$fileName');

    widget.onImagePicked(savedImage.path, DateTime.now());

    // Update existing user or create new one
    if (_box.isNotEmpty) {
      final user = _box.getAt(0)!;
      user.profilePicturePath = savedImage.path;
      user.profilePictureDate = DateTime.now();
      await user.save(); // Save the updated object
    } else {
      // Create a new user if none exists (you might want to get these values from elsewhere)
      final newUser = UserModel(
        username: 'defaultUser', // Replace with actual username
        firstName: 'Default', // Replace with actual first name
        lastName: 'User', // Replace with actual last name
        profilePicturePath: savedImage.path,
        profilePictureDate: DateTime.now(),
      );
      await _box.add(newUser);
    }

    setState(() {
      _imageFile = savedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 70,
        backgroundColor: Colors.white.withOpacity(0.3),
        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
        child:
            _imageFile == null
                ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                : null,
      ),
    );
  }
}
