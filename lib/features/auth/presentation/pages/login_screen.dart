import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innerbalance/core/services/service_locator.dart';
import 'package:innerbalance/core/theme/app_palette.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_event.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_state.dart';
import 'package:innerbalance/features/auth/presentation/pages/register_screen.dart';
import 'package:innerbalance/features/auth/presentation/pages/pending_approval_screen.dart';
import 'package:innerbalance/features/dashboard/presentation/pages/admin_dashboard.dart';
import 'package:innerbalance/features/dashboard/presentation/pages/doctor_dashboard.dart';
import 'package:innerbalance/features/dashboard/presentation/pages/patient_dashboard.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => sl<AuthBloc>(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              String message = state.message;
              if (message.contains('email_not_confirmed')) {
                message = 'Email not confirmed. Please check your inbox or disable "Confirm Email" in Supabase.';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AuthAuthenticated) {
              // Initialize Zego Cloud for Calls
              ZegoUIKitPrebuiltCallInvitationService().init(
                appID: 2061629251, 
                appSign: 'b691c774af97766d7fc3bfcfd63aa1fd8b17e31b999986c33e5c4114c40a0f89',
                userID: state.user.id,
                userName: state.user.name ?? 'User',
                plugins: [ZegoUIKitSignalingPlugin()],
              );

              if (state.user.role == 'admin') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                );
              } else if (state.user.role == 'doctor') {
                if (state.user.isApproved) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorDashboard()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
                  );
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientDashboard()),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'InnerBalance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    AuthLogin(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLoginAnonymous());
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppPalette.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue as Guest',
                            style: TextStyle(fontSize: 16, color: AppPalette.primary),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text('Don\'t have an account? Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
