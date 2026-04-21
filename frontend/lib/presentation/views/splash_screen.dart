import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/providers/secure_storage_provider.dart';
import 'package:frontend/presentation/routes/routes.dart';
import 'package:frontend/util/validators/jwt.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenAndNavigate();
    });
  }

  Future<void> _checkTokenAndNavigate() async {
    final secureStorage = context.read<SecureStorageProvider>();
    final token = await secureStorage.read('token');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _navigateToSignIn();
      return;
    }

    try {
      final role = getRolFromToken(token);
      _navigateByRole(role);
    } catch (e) {
      _navigateToSignIn();
    }
  }

  void _navigateToSignIn() {
    Navigator.pushReplacementNamed(context, Routes.signInScreen);
  }

  void _navigateByRole(String? role) {
    if (role == null) {
      Navigator.pushReplacementNamed(context, Routes.homeScreen);
      return;
    }

    switch (role) {
      case 'TOURIST':
        Navigator.pushReplacementNamed(context, Routes.touristHomeScreen);
        break;
      case 'HOST':
        Navigator.pushReplacementNamed(context, Routes.hostHomeScreen);
        break;
      case 'BUSINESS':
        Navigator.pushReplacementNamed(context, Routes.businessHomeScreen);
        break;
      case 'EXPERIENCE':
        Navigator.pushReplacementNamed(context, Routes.adminHomeScreen);
        break;
      default:
        Navigator.pushReplacementNamed(context, Routes.homeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Eco Spot',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF385C),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFFFF385C),
            ),
          ],
        ),
      ),
    );
  }
}