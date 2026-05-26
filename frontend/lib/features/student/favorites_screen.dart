import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/models/event_model.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/providers/favorites_provider.dart';
import 'package:campus_events_ai/providers/registrations_provider.dart';
import 'package:campus_events_ai/widgets/event_card.dart';
import 'package:campus_events_ai/widgets/loading_widget.dart';
import 'package:campus_events_ai/widgets/empty_state.dart';
import 'package:campus_events_ai/widgets/error_widget.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<EventModel>? _favoriteEvents;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final favIds = ref.read(favoritesProvider).favoriteIds;
      final regIds = ref.read(registrationsProvider).registeredIds;

      if (favIds.isEmpty) {
        setState(() {
          _favoriteEvents = [];
          _isLoading = false;
        });
        return;
      }

      final response = await api.get('/api/events/');
      final allEvents = (response.data as List).map((e) => EventModel.fromJson(e)).toList();
      final favEvents = allEvents.where((e) => favIds.contains(e.id)).toList();
      for (var e in favEvents) {
        e.isFavorite = true;
        e.isRegistered = regIds.contains(e.id);
      }
      setState(() {
        _favoriteEvents = favEvents;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Erreur lors du chargement';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget(message: 'Chargement des favoris...');
    if (_error != null) {
      return ErrorDisplayWidget(message: _error!, onRetry: _loadFavorites);
    }
    if (_favoriteEvents == null || _favoriteEvents!.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.favorite_border,
        title: 'Aucun favori',
        subtitle: 'Ajoutez des événements en favoris avec le cœur ♥',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _favoriteEvents!.length,
        itemBuilder: (context, index) => EventCard(event: _favoriteEvents![index]),
      ),
    );
  }
}
