import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_events_ai/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            accountName: Text(user?.name ?? ''),
            accountEmail: Text(user?.email ?? ''),
          ),
          if (auth.isStudent) ...[
            ListTile(
              leading: const Icon(Icons.explore),
              title: const Text('Explorer'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Mes Favoris'),
              onTap: () {
                Navigator.pop(context);
                context.push('/home/favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('Mes Inscriptions'),
              onTap: () {
                Navigator.pop(context);
                context.push('/home/registrations');
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Assistant IA'),
              onTap: () {
                Navigator.pop(context);
                context.push('/home/assistant');
              },
            ),
          ],
          if (auth.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tableau de bord'),
              onTap: () {
                Navigator.pop(context);
                context.go('/admin');
              },
            ),
          ],
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
