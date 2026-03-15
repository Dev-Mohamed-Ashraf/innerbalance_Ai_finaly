import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:innerbalancee/core/services/service_locator.dart' as di;
import 'package:innerbalancee/core/theme/app_theme.dart';
import 'package:innerbalancee/core/services/zego_cloud_service.dart';
import 'package:innerbalancee/features/auth/presentation/pages/login_screen.dart';
import 'package:innerbalancee/features/ai_engine/presentation/pages/ai_engine_test_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();
  runApp(const InnerBalanceApp());
}

class InnerBalanceApp extends StatefulWidget {
  const InnerBalanceApp({super.key});

  @override
  State<InnerBalanceApp> createState() => _InnerBalanceAppState();
}

class _InnerBalanceAppState extends State<InnerBalanceApp> {
  @override
  void initState() {
    super.initState();
    // Listen to Auth State Changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (session != null) {
        // User is logged in, initialize Zego
        // We use a default name if metadata is missing, or fetch it if possible.
        // For simplicity, we use the email or a placeholder.
        final user = session.user;
        final userName = user.userMetadata?['name'] ?? user.email ?? 'User';
        
        ZegoCloudService.init(
          userID: user.id, 
          userName: userName,
          navigatorKey: navigatorKey,
        );
      } else {
        // User logged out
        ZegoCloudService.uninit();
      }
    });
    
    // Check initial session
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
       final user = session.user;
       final userName = user.userMetadata?['name'] ?? user.email ?? 'User';
       ZegoCloudService.init(
         userID: user.id, 
         userName: userName,
         navigatorKey: navigatorKey,
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InnerBalance',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
