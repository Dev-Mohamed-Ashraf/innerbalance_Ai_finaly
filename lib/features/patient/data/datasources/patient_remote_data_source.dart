import 'package:innerbalance/core/error/exceptions.dart';
import 'package:innerbalance/features/doctor/data/models/article_model.dart';
import 'package:innerbalance/features/doctor/data/models/doctor_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PatientRemoteDataSource {
  Future<List<ArticleModel>> getFeedArticles();
  Future<List<DoctorProfileModel>> getAllDoctors();
  Future<void> sendConnectionRequest(String doctorId);
  Future<String?> getConnectionStatus(String doctorId);
  Future<List<DoctorProfileModel>> getMyDoctors();
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final SupabaseClient supabaseClient;

  PatientRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ArticleModel>> getFeedArticles() async {
    try {
      final response = await supabaseClient
          .from('articles')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((e) => ArticleModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<DoctorProfileModel>> getAllDoctors() async {
    try {
      // Fetch doctor_profiles and join with profiles to get the name
      // Filter by role='doctor' and is_approved=true in the profiles table
      final response = await supabaseClient
          .from('doctor_profiles')
          .select('*, profiles!inner(name, role, is_approved)')
          .eq('profiles.role', 'doctor')
          .eq('profiles.is_approved', true);

      return (response as List).map((e) => DoctorProfileModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendConnectionRequest(String doctorId) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      await supabaseClient.from('connection_requests').insert({
        'patient_id': userId,
        'doctor_id': doctorId,
        'status': 'pending',
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String?> getConnectionStatus(String doctorId) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      final response = await supabaseClient
          .from('connection_requests')
          .select('status')
          .eq('patient_id', userId)
          .eq('doctor_id', doctorId)
          .maybeSingle();

      if (response == null) return null;
      return response['status'] as String;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<DoctorProfileModel>> getMyDoctors() async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      
      // 1. Get accepted doctor IDs
      final requestsResponse = await supabaseClient
          .from('connection_requests')
          .select('doctor_id')
          .eq('patient_id', userId)
          .eq('status', 'accepted');
      
      final doctorIds = (requestsResponse as List).map((e) => e['doctor_id']).toList();

      if (doctorIds.isEmpty) return [];

      // 2. Get doctor details
      final response = await supabaseClient
          .from('doctor_profiles')
          .select('*, profiles!inner(name)')
          .inFilter('id', doctorIds);

      return (response as List).map((e) => DoctorProfileModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
