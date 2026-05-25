import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';

class RegistrationsState {
  final List<int> registeredIds;
  final bool isLoading;

  const RegistrationsState({this.registeredIds = const [], this.isLoading = false});
}

class RegistrationsNotifier extends StateNotifier<RegistrationsState> {
  final ApiService _api;
  final String? _userEmail;

  RegistrationsNotifier(this._api, this._userEmail) : super(const RegistrationsState());

  Future<void> loadRegistrations() async {
    if (_userEmail == null) return;
    state = RegistrationsState(isLoading: true);
    try {
      final response = await _api.get('/api/registrations/', userEmail: _userEmail);
      final ids = (response.data as List).map((e) => e['event_id'] as int).toList();
      state = RegistrationsState(registeredIds: ids);
    } catch (_) {
      state = const RegistrationsState();
    }
  }

  Future<bool> register(int eventId) async {
    if (_userEmail == null) return false;
    try {
      await _api.post('/api/registrations/', data: {'event_id': eventId}, userEmail: _userEmail);
      state = RegistrationsState(registeredIds: [...state.registeredIds, eventId]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelRegistration(int eventId) async {
    if (_userEmail == null) return false;
    try {
      await _api.delete('/api/registrations/$eventId', userEmail: _userEmail);
      state = RegistrationsState(registeredIds: state.registeredIds.where((id) => id != eventId).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isRegistered(int eventId) => state.registeredIds.contains(eventId);
}

final registrationsProvider = StateNotifierProvider<RegistrationsNotifier, RegistrationsState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final user = ref.watch(authProvider).user;
  return RegistrationsNotifier(api, user?.email);
});
