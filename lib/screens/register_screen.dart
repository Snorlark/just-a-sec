import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../config/app_spacing.dart';
import '../config/constants.dart';
import '../custom/custom_button_widget.dart';
import '../custom/custom_text_field.dart';
import '../custom/custom_transition.dart';
import '../models/user_model.dart';
import '../widgets/profile_picture_upload_widget.dart';
import '../widgets/responsive_container_widget.dart';
import 'main_nav_screen.dart';
import 'splash_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _profilePicturePath;
  DateTime? _profilePictureDate;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = UserModel(
        username: _usernameController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        profilePicturePath: _profilePicturePath,
        profilePictureDate: _profilePictureDate,
      );

      final box = Hive.box<UserModel>('userBox');
      await box.put('currentUser', user);

      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));

      print(
        "User saved: ${user.username}, ${user.firstName}, ${user.lastName}, ${user.profilePicturePath}",
      );
      Navigator.of(
        context,
      ).pushReplacement(CustomTransition(page: MainNavScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/register_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ResponsiveContainerWidget(
            child: Padding(
              padding: AppSpacing.allMargin,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CustomButtonWidget(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          CustomTransition(page: SplashScreen()),
                        );
                      },
                      goBack: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/register_text.png',
                    width: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),

                  // Profile picture widget
                  ProfilePictureUploadWidget(
                    onImagePicked: (String path, DateTime date) {
                      setState(() {
                        _profilePicturePath = path;
                        _profilePictureDate = date;
                      });
                    },
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Upload a photo (optional)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: WHITE.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            hintText: "Username",
                            controller: _usernameController,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: WHITE.withOpacity(0.7),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  hintText: "First Name",
                                  controller: _firstNameController,
                                  prefixIcon: Icon(
                                    Icons.badge_outlined,
                                    color: WHITE.withOpacity(0.7),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  hintText: "Last Name",
                                  controller: _lastNameController,
                                  prefixIcon: Icon(
                                    Icons.badge_outlined,
                                    color: WHITE.withOpacity(0.7),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          CustomButtonWidget(
                            onPressed: _handleRegister,
                            text: "Register",
                            isTextButton: true,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
