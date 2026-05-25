import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_events_ai/models/event_model.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/providers/favorites_provider.dart';
import 'package:campus_events_ai/providers/registrations_provider.dart';
import 'package:campus_events_ai/core/helpers.dart';
import 'package:campus_events_ai/widgets/loading_widget.dart';
import 'package:campus_events_ai/widgets/error_widget.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  EventModel? _event;
  bool _isLoading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/api/events/${widget.eventId}');
      final event = EventModel.fromJson(response.data);
      final favIds = ref.read(favoritesProvider).favoriteIds;
      final regIds = ref.read(registrationsProvider).registeredIds;
      event.isFavorite = favIds.contains(event.id);
      event.isRegistered = regIds.contains(event.id);
      setState(() {
        _event = event;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) return Scaffold(appBar: AppBar(), body: const LoadingWidget(message: 'Chargement...'));
    if (_event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorDisplayWidget(
          message: 'Événement introuvable',
          onRetry: _loadEvent,
        ),
      );
    }

    final event = _event!;
    final categoryColor = Helpers.getCategoryColor(event.category);
    final categoryIcon = Helpers.getCategoryIcon(event.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: Icon(
              event.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: event.isFavorite ? Colors.red : null,
            ),
            onPressed: () async {
              final isFav = await ref.read(favoritesProvider.notifier).toggleFavorite(event.id);
              setState(() => event.isFavorite = isFav);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor.withOpacity(0.2), categoryColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon, size: 16, color: categoryColor),
                        const SizedBox(width: 6),
                        Text(
                          event.category,
                          style: TextStyle(color: categoryColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (event.tags != null && event.tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: event.tags!.split(',').map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag.trim(),
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(theme, Icons.calendar_today, 'Date de début', Helpers.formatDateTime(event.startDateTime)),
                  const SizedBox(height: 12),
                  _buildInfoRow(theme, Icons.calendar_today, 'Date de fin', Helpers.formatDateTime(event.endDateTime)),
                  const SizedBox(height: 12),
                  _buildInfoRow(theme, Icons.location_on, 'Lieu', event.locationName),
                  if (event.locationAddress != null && event.locationAddress!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(theme, Icons.map, 'Adresse', event.locationAddress!),
                  ],
                  const SizedBox(height: 12),
                  _buildInfoRow(theme, Icons.person, 'Organisateur', event.organizerName),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    theme,
                    Icons.people,
                    'Capacité',
                    '${event.registrationCount} / ${event.capacity} inscrits',
                  ),
                  if (event.isFullyBooked) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Événement complet',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _actionLoading || event.isFullyBooked
                          ? null
                          : () => _toggleRegistration(event),
                      icon: Icon(event.isRegistered ? Icons.cancel : Icons.event_available),
                      label: Text(
                        event.isRegistered
                            ? 'Annuler l\'inscription'
                            : event.isFullyBooked
                                ? 'Complet'
                                : 'S\'inscrire à cet événement',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.isRegistered ? theme.colorScheme.error : null,
                        foregroundColor: event.isRegistered ? Colors.white : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary,),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }

  Future<void> _toggleRegistration(EventModel event) async {
    setState(() => _actionLoading = true);
    try {
      if (event.isRegistered) {
        final success = await ref.read(registrationsProvider.notifier).cancelRegistration(event.id);
        if (success) {
          setState(() => event.isRegistered = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inscription annulée')),
            );
          }
        }
      } else {
        final success = await ref.read(registrationsProvider.notifier).register(event.id);
        if (success) {
          setState(() => event.isRegistered = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inscription réussie !')),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de l\'inscription')),
          );
        }
      }
    } finally {
      setState(() => _actionLoading = false);
    }
  }
}
