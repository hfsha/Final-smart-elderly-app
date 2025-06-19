import 'package:flutter/material.dart';
import 'package:smart_elderly_app/theme/text_styles.dart';
// No longer need Provider and AuthService imports here
// import 'package:provider/provider.dart';
// import 'package:smart_elderly_app/services/auth_service.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;

  const GreetingHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // final authService = Provider.of<AuthService>(context);
    // final userName = authService.currentUser?.name ?? 'User';

    return Text(
      'Welcome, $userName!',
      style: TextStyles.headline2,
    );
  }
} 