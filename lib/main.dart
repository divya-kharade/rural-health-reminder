// lib/main.dart
import 'package:flutter/material.dart';
import 'package:rural_health_reminder/screens/dashboard_screen.dart';
import 'package:rural_health_reminder/screens/login_screen.dart';
import 'package:rural_health_reminder/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('hi_IN', null);
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: initSettingsAndroid);
  await notifications.initialize(initSettings);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rural Health Reminder',
      theme: ThemeData(
        primarySwatch: Colors.green,
        cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Start on Dashboard
  String _locale = 'en_US'; // Default English
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString('reminders');
    if (remindersJson != null) {
      final List<dynamic> jsonList = jsonDecode(remindersJson);
      setState(() {
        _reminders = jsonList.map((json) => Reminder.fromJson(json)).toList();
      });
    } else {
      // Predefined templates
      _reminders = [
        Reminder(title: 'TB Checkup', date: DateTime.now().add(const Duration(days: 7)), completed: false),
        Reminder(title: 'Vaccination Booster', date: DateTime.now().add(const Duration(days: 14)), completed: false),
        Reminder(title: 'Wellness Check', date: DateTime.now().add(const Duration(days: 30)), completed: false),
      ];
      _saveReminders();
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String remindersJson = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString('reminders', remindersJson);
  }

  void _addReminder(Reminder reminder) {
    setState(() {
      _reminders.add(reminder);
    });
    _saveReminders();
    _scheduleNotification(reminder);
  }

  void _toggleCompleted(int index) {
    setState(() {
      _reminders[index].completed = !_reminders[index].completed;
    });
    _saveReminders();
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final notifications = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'health_channel',
      'Health Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await notifications.show(
      reminder.title.hashCode,
      _getLocalized('reminder_title'),
      '${_getLocalized('reminder_body')} ${reminder.title}',
      details,
      payload: reminder.title,
    );
    // Note: For real scheduling, use zonedSchedule with tz package, but keeping simple for prototype.
  }

  String _getLocalized(String key) {
    // Simple hardcoded localization
    final Map<String, Map<String, String>> translations = {
      'en_US': {
        'app_title': 'Rural Health Reminder',
        'profile': 'Profile',
        'dashboard': 'Dashboard',
        'log': 'Log',
        'age': 'Age',
        'gender': 'Gender',
        'male': 'Male',
        'female': 'female',
        'other': 'Other',
        'add_reminder': 'Add Reminder',
        'title': 'Title',
        'date': 'Date',
        'save': 'Save',
        'upcoming': 'Upcoming Reminders',
        'completed': 'Completed',
        'history': 'Reminder History',
        'reminder_title': 'Health Reminder',
        'reminder_body': 'Time for',
        'language': 'Language: English',
        'switch_lang': 'Switch to Hindi',
      },
      'hi_IN': {
        'app_title': 'ग्रामीण स्वास्थ्य अनुस्मारक',
        'profile': 'प्रोफाइल',
        'dashboard': 'डैशबोर्ड',
        'log': 'लॉग',
        'age': 'उम्र',
        'gender': 'लिंग',
        'male': 'पुरुष',
        'female': 'महिला',
        'other': 'अन्य',
        'add_reminder': 'अनुस्मारक जोड़ें',
        'title': 'शीर्षक',
        'date': 'तारीख',
        'save': 'सहेजें',
        'upcoming': 'आगामी अनुस्मारक',
        'completed': 'पूर्ण',
        'history': 'अनुस्मारक इतिहास',
        'reminder_title': 'स्वास्थ्य अनुस्मारक',
        'reminder_body': 'समय है',
        'language': 'भाषा: हिंदी',
        'switch_lang': 'Switch to English',
      },
    };
    return translations[_locale]?[key] ?? key;
  }

  void _toggleLanguage() {
    setState(() {
      _locale = _locale == 'en_US' ? 'hi_IN' : 'en_US';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProfileScreen(
        locale: _locale,
        getLocalized: _getLocalized,
        addReminder: _addReminder,
        toggleLanguage: _toggleLanguage,
      ),
      DashboardScreen(
        reminders: _reminders,
        getLocalized: _getLocalized,
      ),
      LogScreen(
        reminders: _reminders,
        toggleCompleted: _toggleCompleted,
        getLocalized: _getLocalized,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalized('app_title')),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: _getLocalized('profile')),
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: _getLocalized('dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: _getLocalized('log')),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class Reminder {
  String title;
  DateTime date;
  bool completed;

  Reminder({required this.title, required this.date, required this.completed});

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    title: json['title'],
    date: DateTime.parse(json['date']),
    completed: json['completed'],
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'date': date.toIso8601String(),
    'completed': completed,
  };
}