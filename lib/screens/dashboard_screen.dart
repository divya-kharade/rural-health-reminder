// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class DashboardScreen extends StatelessWidget {
  final List<Reminder> reminders;
  final String Function(String) getLocalized;

  const DashboardScreen({super.key, required this.reminders, required this.getLocalized});

  @override
  Widget build(BuildContext context) {
    final upcoming = reminders.where((r) => !r.completed && r.date.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getLocalized('dashboard'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(getLocalized('upcoming'), style: Theme.of(context).textTheme.titleMedium),
          Expanded(
            child: ListView.builder(
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                final reminder = upcoming[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(reminder.title),
                    subtitle: Text(DateFormat.yMd().format(reminder.date)),
                    trailing: const Icon(Icons.notifications_active, color: Colors.green),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}