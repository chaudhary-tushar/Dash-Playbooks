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
                'onDirectorySelected': (String path) {
                  // Capture context reference immediately to avoid BuildContext sync issues
                  final contextRef = context;

                  // Run the async operation without blocking the UI
                  () async {
                    print('Selected directory: $path');

                    try {
                      // Use the captured context to get ScaffoldMessenger before async calls
                      final messenger = ScaffoldMessenger.of(contextRef);

                      // Show loading indicator
                      const snackBar = SnackBar(
                        content: Text('Scanning directory...'),
                        duration: Duration(milliseconds: 5000),
                      );
                      messenger.showSnackBar(snackBar);

                      // call your scan use case here
                      final scanUseCase = await ref.read(scanLibraryUseCaseProvider.future);

                      final result = await scanUseCase.execute(path);

                      // Hide loading indicator
                      if (contextRef.mounted) {
                        messenger.hideCurrentSnackBar();
                      }

                      print('Scan completed: ${result.scannedFiles} files');
                      print('Errors: ${result.errors}');
                      print('Elapsed time: ${result.elapsedTime}');

                      // Navigate to library screen after successful scan
                      if (result.success) {
                        if (contextRef.mounted) {
                          Navigator.pushNamed(contextRef, '/library');
                        }
                      } else {
                        // Show error message but still navigate
                        if (contextRef.mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Scan completed with errors. Check logs for details.'),
                            ),
                          );
                          Navigator.pushNamed(contextRef, '/library');
                        }
                      }
                    } catch (e) {
                      // Handle error scenario
                      if (contextRef.mounted) {
                        // Hide loading indicator
                        final messenger = ScaffoldMessenger.of(contextRef);
                        messenger.hideCurrentSnackBar();

                        // Show error message
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Error during scan: $e'),
                          ),
                        );
                      }
                      print('Scan error: $e');
                    }
                  }();
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
