import 'package:flutter/material.dart';
import 'package:innerbalancee/core/services/service_locator.dart';
import 'package:innerbalancee/core/theme/app_palette.dart';
import 'package:innerbalancee/features/auth/presentation/pages/login_screen.dart';
import 'package:innerbalancee/features/ai/presentation/pages/ai_health_assessment_page.dart';
import 'package:innerbalancee/features/doctor/data/models/doctor_profile_model.dart';
import 'package:innerbalancee/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorProfilePage extends StatefulWidget {
  final DoctorProfileModel? doctor;
  const DoctorProfilePage({super.key, this.doctor});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _specializationController = TextEditingController();
  final _priceController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // If we have a doctor, show initial data but still fetch full profile to get bio/price
    if (widget.doctor != null) {
      _specializationController.text = widget.doctor!.specialization;
      _priceController.text = widget.doctor!.price.toString();
      _bioController.text = widget.doctor!.bio;
      
      // If we have all important data, don't show loading
      if (widget.doctor!.bio.isNotEmpty) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    final userId = widget.doctor?.id ?? Supabase.instance.client.auth.currentUser!.id;
    final repository = sl<DoctorRepository>();
    final result = await repository.getDoctorProfile(userId);

    result.fold(
      (failure) {
        if (mounted && _isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: ${failure.message}')),
          );
        }
      },
      (profile) {
        if (mounted && profile != null) {
          setState(() {
            _specializationController.text = profile.specialization;
            _priceController.text = profile.price.toString();
            _bioController.text = profile.bio;
            
            // Update the widget doctor if in view mode to ensure UI reflects new data
            if (widget.doctor != null) {
              // We can't mutate widget.doctor, but the UI uses the controllers and local variables
            }
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userId = Supabase.instance.client.auth.currentUser!.id;
    final profile = DoctorProfileModel(
      id: userId,
      name: '', // Name is not updated here
      specialization: _specializationController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      bio: _bioController.text,
      avatarUrl: '', // TODO: Implement image upload
      availableHours: {}, // TODO: Implement schedule picker
    );

    final repository = sl<DoctorRepository>();
    final result = await repository.updateDoctorProfile(profile);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _priceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isViewMode = widget.doctor != null;
    final doctor = widget.doctor;

    return Scaffold(
      appBar: isViewMode ? AppBar(title: Text(doctor?.name ?? 'Doctor Profile')) : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isViewMode) ...[
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[50],
                    child: doctor!.avatarUrl.isNotEmpty
                        ? ClipOval(child: Image.network(doctor.avatarUrl, fit: BoxFit.cover, width: 100, height: 100))
                        : Text(
                            doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    doctor.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    doctor.specialization,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'About',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  doctor.bio,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Consultation Price',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${doctor.price}/hr',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement booking or connection
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ] else ...[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _specializationController,
                        decoration: const InputDecoration(
                          labelText: 'Specialization',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter your specialization' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Consultation Price (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Please enter your price' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) => value!.isEmpty ? 'Please enter your bio' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
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
                        label: const Text('تحليل صحة المريض بالذكاء الاصطناعي'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
