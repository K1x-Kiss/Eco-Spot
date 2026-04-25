import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/repository_interfaces/auth_interface.dart';
import 'package:frontend/presentation/routes/routes.dart';
import 'package:frontend/domain/providers/secure_storage_provider.dart';
import 'package:frontend/domain/providers/user_provider.dart';
import 'package:frontend/util/validators/jwt.dart';
import 'package:frontend/util/validators/validators.dart';
import 'package:frontend/util/location.dart';

class SignInScreen extends StatefulWidget {
  final AuthInterface authInterface;

  const SignInScreen({super.key, required this.authInterface});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final token = await widget.authInterface.signIn(
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (token != null && mounted) {
        final secureStorage = context.read<SecureStorageProvider>();
        await secureStorage.write('token', token);
        if (mounted) {
          final role = getRolFromToken(token);
          _navigateByRole(role);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateByRole(String? role) {
    if (role == null) {
      Navigator.pushReplacementNamed(context, Routes.signInScreen);
      return;
    }

    if (role == 'TOURIST') {
      _showGpsDetectionDialog().then((enabled) {
        _performNavigation(role);
      });
    } else {
      _performNavigation(role);
    }
  }

  Future<void> _performNavigation(String role) async {
    switch (role) {
      case 'TOURIST':
        Navigator.pushReplacementNamed(context, Routes.touristHomeScreen);
        break;
      case 'HOST':
        Navigator.pushReplacementNamed(context, Routes.hostHomeScreen);
        break;
      case 'BUSINESS':
        Navigator.pushReplacementNamed(context, Routes.businessDashboardScreen);
        break;
      case 'EXPERIENCE':
        Navigator.pushReplacementNamed(context, Routes.experienceDashboardScreen);
        break;
      case 'ADMINISTRATOR':
        Navigator.pushReplacementNamed(context, Routes.adminHomeScreen);
        break;
      default:
        Navigator.pushReplacementNamed(context, Routes.signInScreen);
    }
  }

  Future<bool> _showGpsDetectionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enable GPS Location'),
        content: const Text(
          'We can automatically detect your city to show nearby rentals. '
          'Would you like to enable this feature?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF385C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (result == true) {
      return await _detectAndSaveLocation();
    }
    return false;
  }

  Future<bool> _detectAndSaveLocation() async {
    try {
      final hasPermission = await LocationUtils.checkPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS permission is required for automatic detection'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      final locationData = await LocationUtils.getCurrentCityAndCountry();
      if (locationData != null && mounted) {
        final secureStorage = context.read<SecureStorageProvider>();
        await secureStorage.writeLocation(
          locationData['city']!,
          locationData['country']!,
        );
        
        final token = await secureStorage.read('token');
        if (token != null) {
          final userProvider = UserProvider();
          final success = await userProvider.updateLocation(
            token,
            locationData['city']!,
            locationData['country']!,
          );
          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location saved locally. Error updating on server.'),
                backgroundColor: Colors.orange,
              ),
            );
            return true;
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location detected: ${locationData['city']}, ${locationData['country']}',
            ),
            backgroundColor: const Color(0xFFFF385C),
          ),
        );
        return true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error detecting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Eco Spot',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Experience Hospitality, simplified',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: Color(0xFFF7F7F7),
                        ),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            debugPrint('Forgot password tapped');
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Color(0xFFFF385C),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: validatePassword,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF385C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: Color(0xFFFF385C)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.signUpScreen);
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFFFF385C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
