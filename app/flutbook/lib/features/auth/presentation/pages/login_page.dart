import 'package:flutbook/features/auth/presentation/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tablet/Desktop layout breakpoint
        if (constraints.maxWidth >= 800) {
          return const _TabletLayout();
        }

        // Mobile layout
        return const _MobileLayout();
      },
    );
  }
}

// -------------------------------
// MOBILE LAYOUT
// -------------------------------
class _MobileLayout extends ConsumerWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              _LoginHeader(),
              SizedBox(height: 32),
              _LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------
// TABLET / DESKTOP LAYOUT
// -------------------------------
class _TabletLayout extends ConsumerWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Row(
        children: [
          // Illustration Panel
          Expanded(
            flex: 3,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: _LoginIllustration(),
              ),
            ),
          ),

          // Form Panel
          Expanded(
            flex: 2,
            child: Center(
              child: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      _LoginHeader(),
                      SizedBox(height: 32),
                      _LoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------
// LOGIN HEADER
// -------------------------------
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please sign in to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// -------------------------------
// LOGIN ILLUSTRATION
// -------------------------------
class _LoginIllustration extends StatelessWidget {
  const _LoginIllustration();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/login_illustration.png',
      fit: BoxFit.contain,
    );
  }
}

// -------------------------------
// LOGIN FORM
// -------------------------------
class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool passwordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email cannot be empty';
              }
              // RFC 5322 email validation regex
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
            ),
            obscureText: !passwordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password cannot be empty';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement password recovery
              },
              child: const Text('Forgot Password?'),
            ),
          ),

          const SizedBox(height: 16),

          // Error Message
          if (loginState.hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                loginState.error.toString().replaceAll('Exception: ', ''),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),

          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await ref
                      .read(loginProvider.notifier)
                      .login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Login'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
