import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_events_ai/providers/events_provider.dart';
import 'package:campus_events_ai/providers/favorites_provider.dart';
import 'package:campus_events_ai/providers/registrations_provider.dart';
import 'package:campus_events_ai/widgets/event_card.dart';
import 'package:campus_events_ai/widgets/app_drawer.dart';
import 'package:campus_events_ai/widgets/loading_widget.dart';
import 'package:campus_events_ai/widgets/empty_state.dart';
import 'package:campus_events_ai/widgets/error_widget.dart';
import 'package:campus_events_ai/core/constants.dart';
import 'package:campus_events_ai/core/helpers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String? _selectedCategory;
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(eventsProvider.notifier).loadEvents();
      ref.read(favoritesProvider.notifier).loadFavorites();
      ref.read(registrationsProvider.notifier).loadRegistrations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await ref.read(eventsProvider.notifier).searchEvents(query, category: _selectedCategory);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsState = ref.watch(eventsProvider);
    final favIds = ref.watch(favoritesProvider).favoriteIds;
    final regIds = ref.watch(registrationsProvider).registeredIds;

    final displayEvents = _searchController.text.trim().isNotEmpty
        ? _searchResults
        : eventsState.events;

    for (var event in displayEvents) {
      event.isFavorite = favIds.contains(event.id);
      event.isRegistered = regIds.contains(event.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusEvents AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Assistant IA',
            onPressed: () => context.push('/home/assistant'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
            Tab(text: 'Tous'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un événement...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: _performSearch,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip(null, 'Toutes', theme),
                      ...AppConstants.eventCategories.map((cat) => _buildCategoryChip(cat, cat, theme)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? const LoadingWidget(message: 'Recherche...')
                : displayEvents.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.search_off,
                        title: 'Aucun résultat',
                        subtitle: 'Essayez de modifier vos critères de recherche',
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildEventList(eventsState.upcomingEvents, favIds, regIds),
                          _buildEventList(eventsState.pastEvents, favIds, regIds),
                          _buildEventList(displayEvents, favIds, regIds),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label, ThemeData theme) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
          if (_searchController.text.isNotEmpty) _performSearch(_searchController.text);
        },
        selectedColor: theme.colorScheme.primaryContainer,
        checkmarkColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildEventList(List<dynamic> events, List<int> favIds, List<int> regIds) {
    return RefreshIndicator(
      onRefresh: () => ref.read(eventsProvider.notifier).loadEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          event.isFavorite = favIds.contains(event.id);
          event.isRegistered = regIds.contains(event.id);
          return EventCard(event: event);
        },
      ),
    );
  }
}
