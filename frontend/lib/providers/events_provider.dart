import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/models/event_model.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';

class EventsState {
  final List<EventModel> events;
  final List<EventModel> upcomingEvents;
  final List<EventModel> pastEvents;
  final List<String> categories;
  final bool isLoading;
  final String? error;

  const EventsState({
    this.events = const [],
    this.upcomingEvents = const [],
    this.pastEvents = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  EventsState copyWith({
    List<EventModel>? events,
    List<EventModel>? upcomingEvents,
    List<EventModel>? pastEvents,
    List<String>? categories,
    bool? isLoading,
    String? error,
  }) {
    return EventsState(
      events: events ?? this.events,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      pastEvents: pastEvents ?? this.pastEvents,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EventsNotifier extends StateNotifier<EventsState> {
  final ApiService _api;
  final String? _userEmail;

  EventsNotifier(this._api, this._userEmail) : super(const EventsState());

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _api.get('/api/events/', userEmail: _userEmail),
        _api.get('/api/events/upcoming', userEmail: _userEmail),
        _api.get('/api/events/past', userEmail: _userEmail),
        _api.get('/api/events/categories', userEmail: _userEmail),
      ]);

      final events = (results[0].data as List).map((e) => EventModel.fromJson(e)).toList();
      final upcoming = (results[1].data as List).map((e) => EventModel.fromJson(e)).toList();
      final past = (results[2].data as List).map((e) => EventModel.fromJson(e)).toList();
      final categories = (results[3].data as List).cast<String>();

      state = EventsState(
        events: events,
        upcomingEvents: upcoming,
        pastEvents: past,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur lors du chargement des événements');
    }
  }

  Future<List<EventModel>> searchEvents(String query, {String? category}) async {
    try {
      final params = <String, dynamic>{'q': query};
      if (category != null) params['category'] = category;
      final response = await _api.get('/api/events/search', queryParameters: params, userEmail: _userEmail);
      return (response.data as List).map((e) => EventModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<EventModel>> getEventsByCategory(String category) async {
    try {
      final response = await _api.get('/api/events/category/$category', userEmail: _userEmail);
      return (response.data as List).map((e) => EventModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<EventModel?> getEventById(int id) async {
    try {
      final response = await _api.get('/api/events/$id', userEmail: _userEmail);
      return EventModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final user = ref.watch(authProvider).user;
  return EventsNotifier(api, user?.email);
});
