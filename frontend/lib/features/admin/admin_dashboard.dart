import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_events_ai/providers/events_provider.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';
import 'package:campus_events_ai/widgets/event_card.dart';
import 'package:campus_events_ai/widgets/app_drawer.dart';
import 'package:campus_events_ai/widgets/loading_widget.dart';
import 'package:campus_events_ai/widgets/empty_state.dart';
import 'package:campus_events_ai/widgets/error_widget.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(eventsProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsState = ref.watch(eventsProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('!'),
              child: Icon(Icons.event),
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(eventsProvider.notifier).loadEvents(),
        child: _buildBody(theme, eventsState),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel événement'),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, EventsState eventsState) {
    if (eventsState.isLoading) return const LoadingWidget(message: 'Chargement des événements...');

    if (eventsState.error != null) {
      return ErrorDisplayWidget(
        message: eventsState.error!,
        onRetry: () => ref.read(eventsProvider.notifier).loadEvents(),
      );
    }

    if (eventsState.events.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.event_busy,
        title: 'Aucun événement',
        subtitle: 'Créez votre premier événement avec le bouton +',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: eventsState.events.length,
      itemBuilder: (context, index) {
        return EventCard(event: eventsState.events[index]);
      },
    );
  }
}
