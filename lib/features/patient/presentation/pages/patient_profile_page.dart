import 'package:flutter/material.dart';
import 'package:innerbalance/features/auth/presentation/pages/login_screen.dart';
import 'package:innerbalance/features/ai/presentation/pages/ai_health_assessment_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Patient Profile Settings (Coming Soon)'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AIHealthAssessmentPage(),
                ),
              );
            },
            icon: const Icon(Icons.psychology),
            label: const Text('التحليل الصحي بالذكاء الاصطناعي'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
