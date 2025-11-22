import 'package:flutter/material.dart';

class LoginIllustration extends StatelessWidget {
  const LoginIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/login_illustration.png',
      fit: BoxFit.contain,
    );
  }
}
