// lib/screens/log_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class LogScreen extends StatelessWidget {
  final List<Reminder> reminders;
  final void Function(int) toggleCompleted;
  final String Function(String) getLocalized;

  const LogScreen({
    super.key,
    required this.reminders,
    required this.toggleCompleted,
    required this.getLocalized,
  });

  @override
  Widget build(BuildContext context) {
    final completed = reminders.where((r) => r.completed).length;
    final total = reminders.length;
    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), (completed / (total > 0 ? total : 1)) * 100));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getLocalized('log'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(getLocalized('history'), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.green,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(reminder.title),
                    subtitle: Text(DateFormat.yMd().format(reminder.date)),
                    trailing: Checkbox(
                      value: reminder.completed,
                      onChanged: (_) => toggleCompleted(index),
                    ),
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