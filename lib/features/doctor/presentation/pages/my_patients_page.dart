import 'package:flutter/material.dart';
import 'package:innerbalancee/core/services/service_locator.dart';
import 'package:innerbalancee/features/chat/presentation/pages/chat_page.dart';
import 'package:innerbalancee/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyPatientsPage extends StatefulWidget {
  const MyPatientsPage({super.key});

  @override
  State<MyPatientsPage> createState() => _MyPatientsPageState();
}

class _MyPatientsPageState extends State<MyPatientsPage> {
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repository = sl<DoctorRepository>();
    final result = await repository.getMyPatients(userId);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading patients: ${failure.message}')),
          );
        }
      },
      (patients) {
        if (mounted) {
          setState(() {
            _patients = patients;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? const Center(child: Text('No connected patients yet.'))
              : ListView.builder(
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
                    final profile = patient['profiles'];
                    final patientName = profile['name'] ?? 'Unknown Patient';
                    final patientId = patient['patient_id'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(patientName),
                        subtitle: const Text('Connected'),
                        trailing: IconButton(
                          icon: const Icon(Icons.chat),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  otherUserId: patientId,
                                  otherUserName: patientName,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
