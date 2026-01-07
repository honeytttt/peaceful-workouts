import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../shared/widgets/loading_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Title
              const Spacer(),
              _buildAppHeader(),
              const Spacer(flex: 2),
              
              // Google Sign-In Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return LoadingButton(
                    onPressed: () => _signInWithGoogle(context),
                    isLoading: authProvider.isLoading,
                    text: 'Continue with Google',
                    icon: Icons.account_circle,
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Terms & Privacy
              _buildTermsText(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        const Icon(
          Icons.fitness_center,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
        Text(
          'Peaceful Workouts',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share your mindful fitness journey',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.signInWithGoogle();
      // Navigation is handled by AuthWrapper
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTermsText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}