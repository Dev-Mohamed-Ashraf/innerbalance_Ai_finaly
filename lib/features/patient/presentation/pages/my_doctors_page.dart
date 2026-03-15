import 'package:flutter/material.dart';
import 'package:innerbalancee/core/services/service_locator.dart';
import 'package:innerbalancee/core/theme/app_palette.dart';
import 'package:innerbalancee/features/chat/presentation/pages/chat_page.dart';
import 'package:innerbalancee/features/doctor/data/models/doctor_profile_model.dart';
import 'package:innerbalancee/features/patient/data/repositories/patient_repository_impl.dart';

class MyDoctorsPage extends StatefulWidget {
  const MyDoctorsPage({super.key});

  @override
  State<MyDoctorsPage> createState() => _MyDoctorsPageState();
}

class _MyDoctorsPageState extends State<MyDoctorsPage> {
  List<DoctorProfileModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final repository = sl<PatientRepository>();
    final result = await repository.getMyDoctors();

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading doctors: ${failure.message}')),
          );
        }
      },
      (doctors) {
        if (mounted) {
          setState(() {
            _doctors = doctors;
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
          : _doctors.isEmpty
              ? const Center(child: Text('No connected doctors yet.'))
              : ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctors[index];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppPalette.secondary,
                          child: Text(
                            doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(doctor.name),
                        subtitle: Text(doctor.specialization),
                        trailing: IconButton(
                          icon: const Icon(Icons.chat),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  otherUserId: doctor.id,
                                  otherUserName: doctor.name,
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
