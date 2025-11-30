import 'package:innerbalance/core/error/failures.dart';
import 'package:innerbalance/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailPassword(String email, String password);
  Future<UserModel> registerWithEmailPassword(String name, String email, String password, String role);
  Future<UserModel> loginAnonymously();
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> loginWithEmailPassword(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const ServerFailure('User not found');
      }

      // Fetch actual role from 'profiles' table
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: profileData['name'] ?? 'Unknown',
        role: profileData['role'] ?? 'patient',
        isApproved: profileData['is_approved'] ?? false,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmailPassword(String name, String email, String password, String role) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
          'is_approved': role == 'patient', // Patients auto-approved, Doctors need approval
        },
      );
      if (response.user == null) {
        throw const ServerFailure('Registration failed');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> loginAnonymously() async {
    try {
      // Strategy: Create a random "Guest" account using email/password
      // This avoids the need to enable the "Anonymous" provider in Supabase console.
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId = timestamp % 10000;
      final email = 'guest_$timestamp@innerbalance.app';
      final password = 'guest_pass_$timestamp';
      final name = 'Unknown #$randomId';

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': 'patient',
          'is_approved': true,
        },
      );

      if (response.user == null) {
        throw const ServerFailure('Guest login failed');
      }
      
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
  
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }
      return null;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
