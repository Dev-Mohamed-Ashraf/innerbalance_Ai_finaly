import 'package:innerbalancee/core/error/exceptions.dart';
import 'package:innerbalancee/features/doctor/data/models/article_model.dart';
import 'package:innerbalancee/features/doctor/data/models/doctor_profile_model.dart';
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
          .select('*, profiles!doctor_id(name), doctor_profiles!doctor_id(avatar_url)')
          .order('created_at', ascending: false);

      return (response as List).map((e) => ArticleModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<DoctorProfileModel>> getAllDoctors() async {
    try {
      // Query from profiles table instead of doctor_profiles to ensure all doctors are found
      // even if they don't have a specialized profile record yet.
      final response = await supabaseClient
          .from('profiles')
          .select('*, doctor_profiles(*)')
          .eq('role', 'doctor');

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

      // 2. Get doctor details starting from profiles table
      final response = await supabaseClient
          .from('profiles')
          .select('*, doctor_profiles(*)')
          .inFilter('id', doctorIds);

      return (response as List).map((e) => DoctorProfileModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
