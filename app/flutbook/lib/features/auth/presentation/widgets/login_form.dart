import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email address',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
        ),
        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Recovery Password'),
          ),
        ),

        const SizedBox(height: 16),

        // Show error message if there's one
        if (authState.errorMessage != null && !authState.isLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              authState.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),

        // Login button with loading state
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isLoading
              ? null  // Disable button when loading
              : () async {
                  // Perform validation
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  // Check if email is empty or invalid format
                  if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-\.]+)+\.[\w-]{2,4}$').hasMatch(email)) {
                    // Just return without doing anything, error will be shown by the auth provider
                    return;
                  }

                  // Check if password is empty or less than 6 chars
                  if (password.isEmpty || password.length < 6) {
                    // Just return without doing anything, error will be shown by the auth provider
                    return;
                  }

                  // Call auth provider to login
                  await authNotifier.login(email, password);
                },
            child: authState.isLoading
              ? const CircularProgressIndicator()
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Login'),
                ),
          ),
        ),

        const SizedBox(height: 16),

        // Anonymous login button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: authState.isLoading
              ? null  // Disable button when loading
              : () async {
                  // Call auth provider to login anonymously
                  await authNotifier.loginAnonymously();
                },
            child: authState.isLoading
              ? const CircularProgressIndicator()
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Continue as Guest'),
                ),
          ),
        ),
      ],
    );
  }
}
