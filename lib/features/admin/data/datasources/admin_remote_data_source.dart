import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AdminRemoteDataSource {
  Future<List<UserModel>> getPendingDoctors();
  Future<void> approveDoctor(String userId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabaseClient;

  AdminRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<UserModel>> getPendingDoctors() async {
    try {
      // Assuming a 'profiles' table exists that mirrors auth.users metadata
      // OR querying user_metadata if possible (usually restricted).
      // For this MVP, we'll assume we are querying a 'profiles' table.
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('role', 'doctor')
          .eq('is_approved', false);

      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> approveDoctor(String userId) async {
    try {
      // Update the profile
      await supabaseClient
          .from('profiles')
          .update({'is_approved': true})
          .eq('id', userId);
          
      // Ideally, we should also update auth.users metadata via an Edge Function
      // but for this MVP, the app will check the 'profiles' table for status.
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
