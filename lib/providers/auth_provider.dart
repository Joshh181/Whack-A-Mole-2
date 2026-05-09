import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storage = StorageService();

  
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final session = _supabase.auth.currentSession;
      _currentUser = session?.user;
      
      if (_currentUser != null) {
        _storage.setUserId(_currentUser!.id);
        debugPrint('✅ User already logged in: ${_currentUser!.id}');
      }
      
      _supabase.auth.onAuthStateChange.listen((data) {
        _currentUser = data.session?.user;
        
        if (_currentUser != null) {
          _storage.setUserId(_currentUser!.id);
        }
        
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      
      if (_currentUser != null) {
        _storage.setUserId(_currentUser!.id);
        debugPrint('✅ User logged in: ${_currentUser!.id}');
        debugPrint('📧 Email: ${_currentUser!.email}');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      _currentUser = response.user;
      
      if (_currentUser != null) {
        _storage.setUserId(_currentUser!.id);
        debugPrint('✅ New user created: ${_currentUser!.id}');
        debugPrint('📧 Email: ${_currentUser!.email}');
        debugPrint('👤 Username: $username');
        
        await _createUserProfile(username);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      // Trigger the Google Sign-In flow
      // Use the Web Client ID from your Google Cloud Console
      final googleSignIn = GoogleSignIn(
        // The web client ID is needed for Supabase
        serverClientId: '436657469655-sgt8b48ctu5jp1jhfbpe11or26c8hanc.apps.googleusercontent.com',
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _errorMessage = 'Could not get Google ID token';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sign in with Supabase using the Google ID token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      _currentUser = response.user;

      if (_currentUser != null) {
        _storage.setUserId(_currentUser!.id);
        debugPrint('✅ Google Sign-In successful: ${_currentUser!.id}');
        debugPrint('📧 Email: ${_currentUser!.email}');

        // Create profile if new user (upsert to avoid conflicts)
        final displayName = googleUser.displayName ?? 
            googleUser.email.split('@').first;
        await _createUserProfileIfNeeded(displayName);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: ${e.toString()}';
      debugPrint('❌ Google Sign-In error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _createUserProfileIfNeeded(String username) async {
    try {
      // Check if profile already exists
      final existing = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', _currentUser!.id)
          .maybeSingle();

      if (existing == null) {
        await _createUserProfile(username);
      }
    } catch (e) {
      debugPrint('Error checking/creating profile: $e');
    }
  }

  Future<void> _createUserProfile(String username) async {
    try {
      await _supabase.from('profiles').insert({
        'id': _currentUser!.id,
        'username': username,
        'email': _currentUser!.email,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating profile: $e');
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔄 Logging out user: ${_currentUser?.id}');
      
      // Clear user data from storage
      await _storage.clearUserData();
      debugPrint('✅ User data cleared from storage');
      
      // Sign out from Supabase
      await _supabase.auth.signOut();
      _currentUser = null;
      
      debugPrint('✅ User signed out successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error signing out';
      debugPrint('❌ Sign out error: $e');
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final userId = _currentUser?.id;
      if (userId == null) return false;

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🗑️ Deleting full account via RPC for user: $userId');

      // 1. Call the database function to delete all records and the auth account
      await _supabase.rpc('delete_user');
      debugPrint('✅ Server-side deletion successful');

      // 2. Clear local storage
      await _storage.clearUserData();
      debugPrint('✅ Local user data cleared');

      // 3. Clear local session (the account is already deleted from auth.users)
      _currentUser = null;
      debugPrint('✅ Local user session cleared');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting account: $e';
      debugPrint('❌ Account deletion error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String? getUsername() {
    return _currentUser?.userMetadata?['username'] as String?;
  }

  String? getUserId() {
    return _currentUser?.id;
  }
}