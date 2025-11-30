import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innerbalance/core/services/service_locator.dart';
import 'package:innerbalance/core/theme/app_palette.dart';
import 'package:innerbalance/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:innerbalance/features/admin/presentation/bloc/admin_event.dart';
import 'package:innerbalance/features/admin/presentation/bloc/admin_state.dart';
import 'package:innerbalance/features/auth/presentation/pages/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminBloc>()..add(LoadPendingDoctors()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Logout logic here (call AuthBloc)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminError) {
              return Center(child: Text(state.message));
            } else if (state is AdminLoaded) {
              if (state.pendingDoctors.isEmpty) {
                return const Center(child: Text('No pending doctors.'));
              }
              return ListView.builder(
                itemCount: state.pendingDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = state.pendingDoctors[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppPalette.secondary,
                        child: Icon(Icons.person, color: AppPalette.text),
                      ),
                      title: Text(doctor.name),
                      subtitle: Text(doctor.email),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context
                              .read<AdminBloc>()
                              .add(ApproveDoctorEvent(doctor.id));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.primary,
                        ),
                        child: const Text('Approve', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
