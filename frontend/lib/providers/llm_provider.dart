import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';

class LlmState {
  final String? response;
  final bool isLoading;
  final String? error;

  const LlmState({this.response, this.isLoading = false, this.error});
}

class LlmNotifier extends StateNotifier<LlmState> {
  final ApiService _api;
  final String? _userEmail;

  LlmNotifier(this._api, this._userEmail) : super(const LlmState());

  Future<void> sendQuery(String queryType, String queryText) async {
    if (_userEmail == null) return;
    state = LlmState(isLoading: true);
    try {
      final response = await _api.post('/api/llm/query', data: {
        'query_type': queryType,
        'query_text': queryText,
        'user_email': _userEmail,
      });
      final data = response.data;
      if (data['success'] == true) {
        state = LlmState(response: data['response']);
      } else {
        state = LlmState(error: data['response'] ?? 'Erreur de l\'assistant');
      }
    } catch (e) {
      state = LlmState(error: 'Erreur de connexion à l\'assistant IA');
    }
  }

  void clear() {
    state = const LlmState();
  }
}

final llmProvider = StateNotifierProvider<LlmNotifier, LlmState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final user = ref.watch(authProvider).user;
  return LlmNotifier(api, user?.email);
});
