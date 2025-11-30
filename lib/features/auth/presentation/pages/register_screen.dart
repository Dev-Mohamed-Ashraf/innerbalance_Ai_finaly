import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innerbalance/core/services/service_locator.dart';
import 'package:innerbalance/core/theme/app_palette.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_event.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_state.dart';
import 'package:innerbalance/features/auth/presentation/pages/pending_approval_screen.dart';
import 'package:innerbalance/features/dashboard/presentation/pages/admin_dashboard.dart';
import 'package:innerbalance/features/dashboard/presentation/pages/doctor_dashboard.dart';
import 'package:innerbalance/features/dashboard/presentation/pages/patient_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'patient'; // Default role, though UI might only allow Doctor registration if Patients are anon

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: BlocProvider(
        create: (context) => sl<AuthBloc>(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account created!')),
              );
              
              if (state.user.role == 'admin') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                  (route) => false,
                );
              } else if (state.user.role == 'doctor') {
                if (state.user.isApproved) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorDashboard()),
                    (route) => false,
                  );
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
                    (route) => false,
                  );
                }
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientDashboard()),
                  (route) => false,
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
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) =>
                            value!.length < 6 ? 'Password too short' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'I am a...',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'patient', child: Text('Patient')),
                          DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthRegister(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    role: _selectedRole,
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
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
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
