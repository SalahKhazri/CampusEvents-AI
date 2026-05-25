import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_events_ai/models/event_model.dart';
import 'package:campus_events_ai/core/helpers.dart';
import 'package:campus_events_ai/providers/favorites_provider.dart';
import 'package:campus_events_ai/providers/registrations_provider.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';

class EventCard extends ConsumerWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFav = ref.watch(favoritesProvider).favoriteIds.contains(event.id);
    final isReg = ref.watch(registrationsProvider).registeredIds.contains(event.id);
    final categoryColor = Helpers.getCategoryColor(event.category);
    final categoryIcon = Helpers.getCategoryIcon(event.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final route = context.mounted
              ? (ref.read(authProvider).isAdmin ? '/admin/edit/${event.id}' : '/home/events/${event.id}')
              : null;
          if (route != null) context.push(route);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon, size: 14, color: categoryColor),
                        const SizedBox(width: 4),
                        Text(
                          event.category,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!ref.read(authProvider).isAdmin)
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 20,
                      ),
                      onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(event.id),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    Helpers.formatDateTime(event.startDateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.locationName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    '${event.registrationCount}/${event.capacity}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: event.isFullyBooked ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: event.isFullyBooked ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isReg) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Inscrit',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (event.isFullyBooked) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Complet',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
