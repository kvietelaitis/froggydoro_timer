import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:froggydoro/notifications.dart';
import 'package:froggydoro/providers/theme_provider.dart';
import 'package:froggydoro/screens/main_screen.dart';
import 'package:froggydoro/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and populate achievements
  await DatabaseService.instance.populateAchievements();

  // Initialize timezone data
  tz.initializeTimeZones();

  final DatabaseService databaseService = DatabaseService.instance;

  // Initialize notifications
  final notifications = Notifications();
  await notifications.initNotifications();

  final prefs = await SharedPreferences.getInstance();
  final wasActive = prefs.getBool('wasActive') ?? false;

  if (!wasActive) {
    // Check if a timer is picked in the database
    final pickedTimer = await databaseService.getPickedTimer();

    if (pickedTimer != null) {
      // Use the picked timer's settings
      await prefs.setInt('workMinutes', pickedTimer.workDuration);
      await prefs.setInt('breakMinutes', pickedTimer.breakDuration);
      await prefs.setInt('totalSeconds', pickedTimer.workDuration * 60);
      await prefs.setInt('remainingTime', pickedTimer.workDuration * 60);
    } else {
      // Fall back to default values
      final workTime = prefs.getInt('workMinutes') ?? 25;
      await prefs.setInt('totalSeconds', workTime * 60);
      await prefs.setInt('remainingTime', workTime * 60);
    }

    // Reset other timer states
    await prefs.setBool('isRunning', false);
    await prefs.setBool('isBreakTime', false);
    await prefs.setBool('hasStarted', false);
  }

  // Mark as active again
  prefs.setBool('wasActive', true);

  runApp(ProviderScope(child: MyApp(notifications: notifications)));
}

class MyApp extends ConsumerWidget {
  final Notifications notifications;

  const MyApp({super.key, required this.notifications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey, // Ensure navigatorKey is set
      debugShowCheckedModeBanner: false,
      title: 'Work & Break Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFFF1F3E5,
        ), // Light mode background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF1F3E5),
          foregroundColor: Color(0xFF586F51), // Match the background
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF1F3E5),
          selectedItemColor: Color(0xFF586F51),
          unselectedItemColor: Color(0xFFB0C8AE),
          showSelectedLabels: false, // Hide labels
          showUnselectedLabels: false,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFF586F51),
          ), // Light theme text color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFE4E8CD), // Button color
            foregroundColor: Color(0xFF586F51), // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Color(0xFFF1F3E5),
                width: 1,
              ), // Border color and width
            ),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Color(0xFFF1F3E5),
          titleTextStyle: TextStyle(
            color: Color(0xFF586F51),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(color: Color(0xFF586F51), fontSize: 16),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFF3F5738,
        ), // Dark mode background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F5738),
          foregroundColor: Color(0xFFB0C8AE),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF3F5738),
          selectedItemColor: Color(0xFFB0C8AE),
          unselectedItemColor: Color(0xFF63805C),
          showSelectedLabels: false, // Hide labels
          showUnselectedLabels: false,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFFB0C8AE),
          ), // Dark theme text color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF63805C), // Button color
            foregroundColor: Color(0xFFB0C8AE), // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Color(0xFFB0C8AE),
                width: 1,
              ), // Border color and width
            ),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Color(0xFF3F5738),
          titleTextStyle: TextStyle(
            color: Color(0xFFB0C8AE),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(color: Color(0xFFB0C8AE), fontSize: 16),
        ),
      ),
      themeMode: themeMode,
      home: MainScreen(notifications: notifications),
    );
  }
}
