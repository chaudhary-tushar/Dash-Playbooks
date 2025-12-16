import 'package:flutbook/features/auth/presentation/widgets/login_buttons.dart';
import 'package:flutbook/features/auth/presentation/widgets/login_form.dart';
import 'package:flutbook/features/auth/presentation/widgets/login_header.dart';
import 'package:flutbook/features/auth/presentation/widgets/login_illustration.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              LoginHeader(),
              SizedBox(height: 32),
              LoginButtons(),
              SizedBox(height: 24),
              LoginForm(),
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
class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          // Illustration Panel
          Expanded(
            flex: 3,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: LoginIllustration(),
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
                      LoginHeader(),
                      SizedBox(height: 32),
                      LoginButtons(),
                      SizedBox(height: 24),
                      LoginForm(),
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
