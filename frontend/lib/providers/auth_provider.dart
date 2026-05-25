import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/models/user_model.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/services/session_service.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isStudent => user?.isStudent ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  final SessionService _session;

  AuthNotifier(this._api, this._session) : super(const AuthState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await _session.getUser();
    if (user != null) {
      state = AuthState(user: user);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data;
      if (data['success'] == true) {
        final user = UserModel.fromJson(data['user']);
        await _session.saveUser(user);
        state = AuthState(user: user);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] ?? 'Erreur de connexion',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de se connecter au serveur',
      );
    }
  }

  Future<void> logout() async {
    await _session.clearSession();
    state = const AuthState();
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final sessionServiceProvider = Provider<SessionService>((ref) => SessionService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider), ref.watch(sessionServiceProvider));
});
