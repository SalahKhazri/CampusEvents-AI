import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/models/event_model.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/providers/favorites_provider.dart';
import 'package:campus_events_ai/providers/registrations_provider.dart';
import 'package:campus_events_ai/widgets/event_card.dart';
import 'package:campus_events_ai/widgets/loading_widget.dart';
import 'package:campus_events_ai/widgets/empty_state.dart';
import 'package:campus_events_ai/widgets/error_widget.dart';

class RegistrationsScreen extends ConsumerStatefulWidget {
  const RegistrationsScreen({super.key});

  @override
  ConsumerState<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends ConsumerState<RegistrationsScreen> {
  List<EventModel>? _registeredEvents;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final regIds = ref.read(registrationsProvider).registeredIds;
      final favIds = ref.read(favoritesProvider).favoriteIds;

      if (regIds.isEmpty) {
        setState(() {
          _registeredEvents = [];
          _isLoading = false;
        });
        return;
      }

      final response = await api.get('/api/events/');
      final allEvents = (response.data as List).map((e) => EventModel.fromJson(e)).toList();
      final regEvents = allEvents.where((e) => regIds.contains(e.id)).toList();
      for (var e in regEvents) {
        e.isFavorite = favIds.contains(e.id);
        e.isRegistered = true;
      }
      setState(() {
        _registeredEvents = regEvents;
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
      appBar: AppBar(title: const Text('Mes Inscriptions')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget(message: 'Chargement des inscriptions...');
    if (_error != null) {
      return ErrorDisplayWidget(message: _error!, onRetry: _loadRegistrations);
    }
    if (_registeredEvents == null || _registeredEvents!.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.event_note,
        title: 'Aucune inscription',
        subtitle: 'Inscrivez-vous à des événements depuis le catalogue',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadRegistrations,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _registeredEvents!.length,
        itemBuilder: (context, index) => EventCard(event: _registeredEvents![index]),
      ),
    );
  }
}
