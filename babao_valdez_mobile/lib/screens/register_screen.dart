import 'package:flutter/material.dart';

import '../config/app_spacing.dart';
import '../config/constants.dart';
import '../custom/custom_button_widget.dart';
import '../custom/custom_text_field.dart';
import '../custom/custom_transition.dart';
import '../widgets/profile_picture_upload_widget.dart';
import '../widgets/responsive_container_widget.dart';
import 'main_nav_screen.dart';
import 'splash_screen.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _typeController = TextEditingController(text: 'user');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isActive = true;
  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String _gender = 'Female';
  String _userType = 'editor';

  String? _profilePicturePath;
  DateTime? _profilePictureDate;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _typeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);
    try {
      final userService = UserService();
      final response = await userService.registerUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: _ageController.text.trim(),
        gender: _gender,
        contactNumber: _contactNumberController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        address: _addressController.text.trim(),
        type: _userType,
        isActive: _isActive,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
      );
      // Persist the newly registered user so AccountScreen can show details immediately
      final merged = {
        ...response,
        'user': {
          if (response['user'] is Map) ...response['user'],
          // ensure required fields from the form are present
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'age': _ageController.text.trim(),
          'gender': _gender,
          'contactNumber': _contactNumberController.text.trim(),
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'address': _addressController.text.trim(),
          'type': _userType,
          'isActive': _isActive,
          // try to capture id if backend returns it at top-level
          if (response['_id'] != null) '_id': response['_id'],
          if (response['id'] != null) 'id': response['id'],
        }
      };
      await userService.saveUserData(merged);
      // Optionally refresh from backend to capture any server-side defaults
      await userService.fetchAndCacheCurrentUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.of(context).pushReplacement(CustomTransition(page: MainNavScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Upload a photo (optional)',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: WHITE.withOpacity(0.4),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            hintText: "Username",
                            controller: _usernameController,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.white.withOpacity(0.7),
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
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  hintText: "Age",
                                  controller: _ageController,
                                  prefixIcon: Icon(
                                    Icons.numbers,
                                    color: WHITE.withOpacity(0.7),                                    
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your age';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Age must be a number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.wc, color: Colors.white70),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _gender,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          dropdownColor: PRIMARY,
                                          iconEnabledColor: Colors.white,
                                          style: const TextStyle(color: Colors.white),
                                          items: const [
                                            DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(color: Colors.white))),
                                            DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(color: Colors.white))),
                                          ],
                                          onChanged: (v) => setState(() => _gender = v ?? 'Female'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  hintText: "Contact Number",
                                  controller: _contactNumberController,
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    color: WHITE.withOpacity(0.7),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your contact number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  hintText: "Email",
                                  controller: _emailController,
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: WHITE.withOpacity(0.7),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            hintText: "Address",
                            controller: _addressController,
                            prefixIcon: Icon(
                              Icons.home_outlined,
                              color: WHITE.withOpacity(0.7),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            hintText: "Password",
                            controller: _passwordController,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: WHITE.withOpacity(0.7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            obscureText: !_showPassword,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "Confirm Password",
                            controller: _confirmPasswordController,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: WHITE.withOpacity(0.7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            obscureText: !_showConfirmPassword,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Switch(
                                  value: _isActive,
                                  onChanged: (v) => setState(() => _isActive = v),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Active',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: WHITE.withOpacity(0.9),
                                      ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person_pin, color: Colors.white70),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            value: _userType,
                                            decoration: const InputDecoration(border: InputBorder.none),
                                            dropdownColor: PRIMARY,
                                            iconEnabledColor: Colors.white,
                                            style: const TextStyle(color: Colors.white),
                                            items: const [
                                              DropdownMenuItem(value: 'admin', child: Text('admin', style: TextStyle(color: Colors.white))),
                                              DropdownMenuItem(value: 'editor', child: Text('editor', style: TextStyle(color: Colors.white))),
                                              DropdownMenuItem(value: 'viewer', child: Text('viewer', style: TextStyle(color: Colors.white))),
                                            ],
                                            onChanged: (v) => setState(() => _userType = v ?? 'editor'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomButtonWidget(
                            onPressed: _isSubmitting ? (){} : _handleRegister,
                            text: _isSubmitting ? "Submitting..." : "Register",
                            isTextButton: true,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
