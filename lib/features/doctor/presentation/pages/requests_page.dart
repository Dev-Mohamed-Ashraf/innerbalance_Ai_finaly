import 'package:flutter/material.dart';
import 'package:innerbalancee/core/services/service_locator.dart';
import 'package:innerbalancee/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repository = sl<DoctorRepository>();
    final result = await repository.getPendingRequests(userId);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading requests: ${failure.message}')),
          );
        }
      },
      (requests) {
        if (mounted) {
          setState(() {
            _requests = requests;
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

  Future<void> _updateStatus(String requestId, String status) async {
    final repository = sl<DoctorRepository>();
    final result = await repository.updateRequestStatus(requestId, status);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $status')),
        );
        _loadRequests(); // Refresh list
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No pending requests.'))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    final patientName = request['profiles']['name'] ?? 'Unknown Patient';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(patientName),
                        subtitle: const Text('Wants to connect with you'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _updateStatus(request['id'], 'accepted'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _updateStatus(request['id'], 'rejected'),
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
