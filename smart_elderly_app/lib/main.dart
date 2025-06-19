import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_elderly_app/api/api_service.dart';
import 'package:smart_elderly_app/pages/auth/login_page.dart';
import 'package:smart_elderly_app/pages/auth/signup_page.dart';
import 'package:smart_elderly_app/pages/dashboard/dashboard_page.dart';
import 'package:smart_elderly_app/pages/logs/logs_page.dart';
import 'package:smart_elderly_app/pages/settings/settings_page.dart';
import 'package:smart_elderly_app/pages/splash_page.dart';
import 'package:smart_elderly_app/pages/trends/trends_page.dart';
import 'package:smart_elderly_app/pages/main_screen.dart';
import 'package:smart_elderly_app/services/auth_service.dart';
import 'package:smart_elderly_app/services/notification_service.dart';
import 'package:smart_elderly_app/services/sensor_service.dart';
import 'package:smart_elderly_app/theme/app_theme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      const InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize services
  final apiService = ApiService(client: http.Client());
  final authService = AuthService(apiService: apiService);
  await authService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(
          create: (_) => SensorService(apiService: apiService),
        ),
        Provider(
          create: (_) => NotificationService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Elderly Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/main': (context) => const MainScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/trends': (context) => const TrendsPage(),
        '/logs': (context) => const LogsPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
