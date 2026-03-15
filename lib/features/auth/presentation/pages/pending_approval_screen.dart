import 'package:flutter/material.dart';
import 'package:innerbalancee/core/theme/app_palette.dart';
import 'package:innerbalancee/features/auth/presentation/pages/login_screen.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_empty_rounded,
              size: 80,
              color: AppPalette.secondary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Pending Approval',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your doctor account is currently under review by the administrator. Please check back later.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
