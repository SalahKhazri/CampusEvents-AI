import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_events_ai/core/theme.dart';
import 'package:campus_events_ai/routes/app_router.dart';
import 'package:campus_events_ai/services/session_service.dart';
import 'package:campus_events_ai/core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionService = SessionService();
  final isDark = await sessionService.getThemeMode();

  runApp(
    ProviderScope(
      overrides: [],
      child: CampusEventsApp(isDark: isDark),
    ),
  );
}

class CampusEventsApp extends ConsumerStatefulWidget {
  final bool isDark;

  const CampusEventsApp({super.key, required this.isDark});

  @override
  ConsumerState<CampusEventsApp> createState() => _CampusEventsAppState();
}

class _CampusEventsAppState extends ConsumerState<CampusEventsApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  void _toggleTheme() async {
    setState(() => _isDark = !_isDark);
    final sessionService = SessionService();
    await sessionService.setThemeMode(_isDark);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
