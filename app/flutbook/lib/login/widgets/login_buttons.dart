import 'package:flutter/material.dart';

class LoginButtons extends StatelessWidget {
  const LoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LoginButton(
          iconPath: 'assets/icons/google.png',
          label: 'Continue with Google',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _LoginButton(
          iconPath: 'assets/icons/facebook.png',
          label: 'Continue with Facebook',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _LoginButton(
          iconPath: 'assets/icons/apple.png',
          label: 'Continue with Apple',
          onTap: () {},
        ),
        const SizedBox(height: 24),
        const Divider(),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, height: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
