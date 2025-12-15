import 'package:flutbook/core/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// class LoginButtons extends StatelessWidget {
class LoginButtons extends ConsumerWidget {
  const LoginButtons({super.key});

  @override
  // Widget build(BuildContext context) {
  Widget build(BuildContext context, WidgetRef ref) {
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
          onTap: () {
            Navigator.pushNamed(
              context,
              '/directory',
              arguments: {
                'initialDirectory': '',
                'onDirectorySelected': (String path) async {
                  print('Selected directory: $path');

                  try {
                    // Show loading indicator
                    const snackBar = SnackBar(
                      content: Text('Scanning directory...'),
                      duration: Duration(milliseconds: 5000),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    // call your scan use case here
                    final scanUseCase = await ref.read(scanLibraryUseCaseProvider.future);

                    final result = await scanUseCase.execute(path);

                    // Hide loading indicator
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    print('Scan completed: ${result.scannedFiles} files');
                    print('Errors: ${result.errors}');
                    print('Elapsed time: ${result.elapsedTime}');

                    // Navigate to library screen after successful scan
                    if (result.success) {
                      Navigator.pushNamed(context, '/library');
                    } else {
                      // Show error message but still navigate
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Scan completed with errors. Check logs for details.'),
                        ),
                      );
                      Navigator.pushNamed(context, '/library');
                    }
                  } catch (e) {
                    // Hide loading indicator
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error during scan: $e'),
                      ),
                    );
                    print('Scan error: $e');
                  }
                },
              },
            );
          },
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
