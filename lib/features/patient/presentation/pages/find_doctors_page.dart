import 'package:flutter/material.dart';
import 'package:innerbalancee/core/services/service_locator.dart';
import 'package:innerbalancee/core/theme/app_palette.dart';
import 'package:innerbalancee/features/doctor/data/models/doctor_profile_model.dart';
import 'package:innerbalancee/features/doctor/presentation/pages/doctor_profile_page.dart';
import 'package:innerbalancee/features/patient/data/repositories/patient_repository_impl.dart';

class FindDoctorsPage extends StatefulWidget {
  const FindDoctorsPage({super.key});

  @override
  State<FindDoctorsPage> createState() => _FindDoctorsPageState();
}

class _FindDoctorsPageState extends State<FindDoctorsPage> {
  List<DoctorProfileModel> _allDoctors = [];
  List<DoctorProfileModel> _filteredDoctors = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, String> _connectionStatuses = {}; // doctorId -> status
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredDoctors = _allDoctors
          .where((doctor) =>
              doctor.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              doctor.specialization.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
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
            _allDoctors = doctors;
            _filteredDoctors = doctors;
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
      appBar: AppBar(
        title: const Text('Find Your Doctor'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialization...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredDoctors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No doctors found matching your search.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _filteredDoctors[index];
                    final status = _connectionStatuses[doctor.id] ?? 'none';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorProfilePage(doctor: doctor),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.blue[50],
                                    child: doctor.avatarUrl.isNotEmpty
                                        ? ClipOval(child: Image.network(doctor.avatarUrl, fit: BoxFit.cover, width: 70, height: 70))
                                        : Text(
                                            doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
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
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            doctor.specialization,
                                            style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                                            Text(
                                              '${doctor.price}/hr',
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (doctor.bio.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  doctor.bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[600], height: 1.4),
                                ),
                              ],
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: status == 'none'
                                      ? () => _sendRequest(doctor.id)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: status == 'none'
                                        ? Colors.blue
                                        : Colors.grey[300],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    status == 'none'
                                        ? 'Connect'
                                        : status == 'pending'
                                            ? 'Request Pending'
                                            : 'Connected',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: status == 'none' ? Colors.white : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
