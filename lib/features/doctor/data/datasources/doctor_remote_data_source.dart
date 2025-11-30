import 'package:innerbalance/core/error/exceptions.dart';
import 'package:innerbalance/features/doctor/data/models/article_model.dart';
import 'package:innerbalance/features/doctor/data/models/doctor_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DoctorRemoteDataSource {
  Future<DoctorProfileModel?> getDoctorProfile(String userId);
  Future<void> updateDoctorProfile(DoctorProfileModel profile);
  Future<void> createArticle(ArticleModel article);
  Future<List<ArticleModel>> getDoctorArticles(String doctorId);
  Future<List<Map<String, dynamic>>> getPendingRequests(String doctorId);
  Future<void> updateRequestStatus(String requestId, String status);
  Future<List<Map<String, dynamic>>> getMyPatients(String doctorId);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final SupabaseClient supabaseClient;

  DoctorRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<DoctorProfileModel?> getDoctorProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('doctor_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return DoctorProfileModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateDoctorProfile(DoctorProfileModel profile) async {
    try {
      await supabaseClient.from('doctor_profiles').upsert(profile.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createArticle(ArticleModel article) async {
    try {
      await supabaseClient.from('articles').insert(article.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ArticleModel>> getDoctorArticles(String doctorId) async {
    try {
      final response = await supabaseClient
          .from('articles')
          .select()
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => ArticleModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(String doctorId) async {
    try {
      final response = await supabaseClient
          .from('connection_requests')
          .select('*, profiles!patient_id(name)')
          .eq('doctor_id', doctorId)
          .eq('status', 'pending');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await supabaseClient
          .from('connection_requests')
          .update({'status': status})
          .eq('id', requestId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getMyPatients(String doctorId) async {
    try {
      final response = await supabaseClient
          .from('connection_requests')
          .select('*, profiles!patient_id(*)')
          .eq('doctor_id', doctorId)
          .eq('status', 'accepted');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
