import 'package:flutbook/core/services/navigation_service.dart';
import 'package:flutbook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email address',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.visibility_off),
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

        const SizedBox(height: 8),

        // Unified authentication button with loading state (login/signup combined)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isLoading
                ? null // Disable button when loading
                : () async {
                    // Check if auth is already loading to prevent multiple clicks
                    final currentAuthState = ref.read(authProvider);
                    if (currentAuthState.isLoading) {
                      print('Authentication already in progress, ignoring click');
                      return;
                    }

                    // Perform validation
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    // Check if email is empty or invalid format
                    if (email.isEmpty ||
                        !RegExp(
                          r'^[\w-\.]+@([\w-\.]+)+\.[\w-]{2,4}$',
                        ).hasMatch(email)) {
                      // Just return without doing anything, error will be shown by the auth provider
                      return;
                    }

                    // Check if password is empty or less than 6 chars
                    if (password.isEmpty || password.length < 6) {
                      // Just return without doing anything, error will be shown by the auth provider
                      return;
                    }

                    // Call auth provider to authenticate (unified login/signup)
                    await authNotifier.authenticate(email, password);

                    // After successful authentication, navigate to library
                    final updatedAuthState = ref.read(authProvider);
                    if (updatedAuthState.isAuthenticated) {
                      await NavigationService.navigateToLibrary();
                    }
                  },
            child: authState.isLoading
                ? const CircularProgressIndicator()
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Login or Sign Up'),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Anonymous login button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: authState.isLoading
                ? null // Disable button when loading
                : () async {
                    // Check if auth is already loading to prevent multiple clicks
                    final currentAuthState = ref.read(authProvider);
                    if (currentAuthState.isLoading) {
                      print('Anonymous login already in progress, ignoring click');
                      return;
                    }

                    // Call auth provider to login anonymously
                    await ref.read(authProvider.notifier).loginAnonymously();
                    // After successful anonymous login, navigate to library
                    final updatedAuthState = ref.read(authProvider);
                    if (updatedAuthState.isAuthenticated) {
                      await NavigationService.navigateToLibrary();
                    }
                  },
            child: authState.isLoading
                ? const CircularProgressIndicator()
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Continue as Guest'),
                  ),
          ),
        ),

        // Skip button for development
        // const SizedBox(height: 16),
        // SizedBox(
        //   width: double.infinity,
        //   child: TextButton(
        //     onPressed: () {
        //       // Navigate directly to directory selection
        //       Navigator.pushNamed(context, '/directory', arguments: {
        //         'initialDirectory': '',
        //       });
        //     },
        //     child: const Padding(
        //       padding: EdgeInsets.symmetric(vertical: 14),
        //       child: Text('Skip for Development'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
