import 'package:flutter/material.dart';
import 'package:innerbalance/core/services/service_locator.dart';
import 'package:innerbalance/core/theme/app_palette.dart';
import 'package:innerbalance/features/auth/presentation/pages/login_screen.dart';
import 'package:innerbalance/features/ai/presentation/pages/ai_health_assessment_page.dart';
import 'package:innerbalance/features/doctor/data/models/doctor_profile_model.dart';
import 'package:innerbalance/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

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
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repository = sl<DoctorRepository>();
    final result = await repository.getDoctorProfile(userId);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: ${failure.message}')),
          );
        }
      },
      (profile) {
        if (profile != null) {
          _specializationController.text = profile.specialization;
          _priceController.text = profile.price.toString();
          _bioController.text = profile.bio;
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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
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
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your specialization' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Consultation Price (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your price' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your bio' : null,
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
        ),
      ),
    );
  }
}
