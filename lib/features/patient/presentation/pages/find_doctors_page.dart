import 'package:flutter/material.dart';
import 'package:innerbalance/core/services/service_locator.dart';
import 'package:innerbalance/core/theme/app_palette.dart';
import 'package:innerbalance/features/doctor/data/models/doctor_profile_model.dart';
import 'package:innerbalance/features/patient/data/repositories/patient_repository_impl.dart';

class FindDoctorsPage extends StatefulWidget {
  const FindDoctorsPage({super.key});

  @override
  State<FindDoctorsPage> createState() => _FindDoctorsPageState();
}

class _FindDoctorsPageState extends State<FindDoctorsPage> {
  List<DoctorProfileModel> _doctors = [];
  Map<String, String> _connectionStatuses = {}; // doctorId -> status
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final repository = sl<PatientRepository>();
    final result = await repository.getAllDoctors();

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading doctors: ${failure.message}')),
          );
        }
      },
      (doctors) async {
        if (mounted) {
          setState(() {
            _doctors = doctors;
          });
          // Load connection status for each doctor
          for (var doctor in doctors) {
            _checkStatus(doctor.id);
          }
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkStatus(String doctorId) async {
    final repository = sl<PatientRepository>();
    final result = await repository.getConnectionStatus(doctorId);
    
    result.fold(
      (l) => null,
      (status) {
        if (mounted) {
          setState(() {
            _connectionStatuses[doctorId] = status ?? 'none';
          });
        }
      },
    );
  }

  Future<void> _sendRequest(String doctorId) async {
    final repository = sl<PatientRepository>();
    final result = await repository.sendConnectionRequest(doctorId);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending request: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
        setState(() {
          _connectionStatuses[doctorId] = 'pending';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? const Center(child: Text('No doctors found.'))
              : ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctors[index];
                    final status = _connectionStatuses[doctor.id] ?? 'none';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppPalette.secondary,
                                  child: Text(
                                    doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        doctor.specialization,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        '\$${doctor.price}/hr',
                                        style: const TextStyle(
                                          color: AppPalette.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(doctor.bio),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: status == 'none'
                                    ? () => _sendRequest(doctor.id)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: status == 'none'
                                      ? AppPalette.primary
                                      : Colors.grey,
                                ),
                                child: Text(
                                  status == 'none'
                                      ? 'Connect'
                                      : status == 'pending'
                                          ? 'Request Pending'
                                          : 'Connected',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
