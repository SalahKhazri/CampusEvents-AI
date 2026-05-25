import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';

class FavoritesState {
  final List<int> favoriteIds;
  final bool isLoading;

  const FavoritesState({this.favoriteIds = const [], this.isLoading = false});
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final ApiService _api;
  final String? _userEmail;

  FavoritesNotifier(this._api, this._userEmail) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    if (_userEmail == null) return;
    state = FavoritesState(isLoading: true);
    try {
      final response = await _api.get('/api/favorites/', userEmail: _userEmail);
      final ids = (response.data as List).map((e) => e['event_id'] as int).toList();
      state = FavoritesState(favoriteIds: ids);
    } catch (_) {
      state = const FavoritesState();
    }
  }

  Future<bool> toggleFavorite(int eventId) async {
    if (_userEmail == null) return false;
    try {
      final response = await _api.post('/api/favorites/toggle', data: {'event_id': eventId}, userEmail: _userEmail);
      final isFav = response.data['is_favorite'] == true;
      if (isFav) {
        state = FavoritesState(favoriteIds: [...state.favoriteIds, eventId]);
      } else {
        state = FavoritesState(favoriteIds: state.favoriteIds.where((id) => id != eventId).toList());
      }
      return isFav;
    } catch (_) {
      return state.favoriteIds.contains(eventId);
    }
  }

  bool isFavorite(int eventId) => state.favoriteIds.contains(eventId);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final user = ref.watch(authProvider).user;
  return FavoritesNotifier(api, user?.email);
});
