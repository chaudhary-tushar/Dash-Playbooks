// lib/presentation/screens/auth_screen.dart
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.headset,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 24),
            Text(
              'Audiobook Player',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Enjoy your audiobooks with or without an account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 48),
            
            // Continue as Guest option (primary path for US1)
            ElevatedButton(
              onPressed: () {
                // Navigate to directory selection for anonymous users
                Navigator.pushReplacementNamed(context, '/directory_selection');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline),
                  SizedBox(width: 12),
                  Text('Continue as Guest'),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Divider with "or" text
            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'or',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            SizedBox(height: 16),
            
            // Sign in options
            OutlinedButton.icon(
              onPressed: () {
                // Handle email/password sign in
              },
              icon: Icon(Icons.email_outlined),
              label: Text('Sign in with Email'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 12),
            
            OutlinedButton.icon(
              onPressed: () {
                // Handle Google sign in
              },
              icon: Icon(Icons.people_alt_outlined), // Google icon approximation
              label: Text('Sign in with Google'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 24),
            
            TextButton(
              onPressed: () {
                // Navigate to terms of service/privacy policy
              },
              child: Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}