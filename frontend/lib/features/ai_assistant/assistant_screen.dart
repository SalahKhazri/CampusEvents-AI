import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/providers/llm_provider.dart';
import 'package:campus_events_ai/widgets/loading_widget.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _recommendController = TextEditingController();
  final _planningController = TextEditingController();
  final _qaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _recommendController.dispose();
    _planningController.dispose();
    _qaController.dispose();
    super.dispose();
  }

  void _sendQuery(String type, String text) {
    if (text.trim().isEmpty) return;
    ref.read(llmProvider.notifier).sendQuery(type, text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final llmState = ref.watch(llmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Recherche'),
            Tab(icon: Icon(Icons.recommend), text: 'Recommandation'),
            Tab(icon: Icon(Icons.schedule), text: 'Planning'),
            Tab(icon: Icon(Icons.help_outline), text: 'Questions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(theme, llmState),
          _buildRecommendTab(theme, llmState),
          _buildPlanningTab(theme, llmState),
          _buildQATab(theme, llmState),
        ],
      ),
    );
  }

  Widget _buildSearchTab(ThemeData theme, LlmState llmState) {
    return _buildModule(
      theme: theme,
      title: 'Recherche en langage naturel',
      description: 'Décris l\'événement que tu cherches en langage naturel',
      hint: 'Ex: Je cherche un workshop IA ce weekend',
      icon: Icons.search,
      controller: _searchController,
      queryType: 'search',
      llmState: llmState,
    );
  }

  Widget _buildRecommendTab(ThemeData theme, LlmState llmState) {
    return _buildModule(
      theme: theme,
      title: 'Recommandation personnalisée',
      description: 'Obtiens des recommandations basées sur tes favoris et inscriptions',
      hint: 'Ex: Que me recommandes-tu ?',
      icon: Icons.recommend,
      controller: _recommendController,
      queryType: 'recommendation',
      llmState: llmState,
    );
  }

  Widget _buildPlanningTab(ThemeData theme, LlmState llmState) {
    return _buildModule(
      theme: theme,
      title: 'Planification intelligente',
      description: 'Indique tes contraintes pour un planning personnalisé',
      hint: 'Ex: J\'ai cours lundi matin et un exam jeudi',
      icon: Icons.schedule,
      controller: _planningController,
      queryType: 'planning',
      llmState: llmState,
    );
  }

  Widget _buildQATab(ThemeData theme, LlmState llmState) {
    return _buildModule(
      theme: theme,
      title: 'Questions sur le catalogue',
      description: 'Pose des questions sur les événements disponibles',
      hint: 'Ex: Quels événements sont utiles pour la data science ?',
      icon: Icons.help_outline,
      controller: _qaController,
      queryType: 'qa',
      llmState: llmState,
    );
  }

  Widget _buildModule({
    required ThemeData theme,
    required String title,
    required String description,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String queryType,
    required LlmState llmState,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary.withOpacity(0.1), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                  suffixIcon: llmState.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _sendQuery(queryType, controller.text),
                        ),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (v) => _sendQuery(queryType, v),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildResponse(llmState, theme),
        ),
      ],
    );
  }

  Widget _buildResponse(LlmState llmState, ThemeData theme) {
    if (llmState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: LoadingWidget(message: 'L\'assistant réfléchit...'),
      );
    }

    if (llmState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                llmState.error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (llmState.response != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_awesome, size: 20, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  'Réponse de l\'assistant',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: SelectableText(
                llmState.response!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => ref.read(llmProvider.notifier).clear(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Nouvelle question'),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.15)),
            const SizedBox(height: 16),
            Text(
              'Pose une question à l\'assistant',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilise le champ ci-dessus pour discuter avec l\'IA',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
