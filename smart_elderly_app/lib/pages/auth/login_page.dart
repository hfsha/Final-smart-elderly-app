import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/services/auth_service.dart';
import 'package:smart_elderly_app/utils/validators.dart';
import 'package:smart_elderly_app/widgets/custom_textfield.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.gradientPurple, AppColors.gradientBlue],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  Animate(
                    effects: [FadeEffect(duration: 800.ms), ScaleEffect(duration: 800.ms)],
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      child: Image.asset(
                        'assets/images/splash2_icon.png',
                        width: 320,
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Animate(
                    effects: [FadeEffect(duration: 600.ms, delay: 200.ms), SlideEffect(begin: Offset(0, 0.2), end: Offset.zero, duration: 600.ms)],
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Welcome Back',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gradientPurple,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Login to monitor your elderly',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                prefixIcon: const Icon(Icons.email),
                                keyboardType: TextInputType.emailAddress,
                                validator: AppValidators.validateEmail,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                obscureText: _obscurePassword,
                                validator: AppValidators.validatePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password
                                  },
                                  child: const Text('Forgot Password?'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gradientPurple,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: authService.isLoading ? null : () => _login(authService),
                                child: authService.isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account?"),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                    child: const Text('Sign Up'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login(AuthService authService) async {
    if (_formKey.currentState!.validate()) {
      try {
        await authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
