import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final String locale;
  final String Function(String) getLocalized;
  final void Function(Reminder) addReminder;
  final VoidCallback toggleLanguage;

  const ProfileScreen({
    super.key,
    required this.locale,
    required this.getLocalized,
    required this.addReminder,
    required this.toggleLanguage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _age = '';
  String _gender = 'Male';
  String _title = '';
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.getLocalized('profile'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: widget.getLocalized('age')),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _age = value,
                  ),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(widget.getLocalized(g.toLowerCase()))))
                        .toList(),
                    onChanged: (value) => setState(() => _gender = value!),
                    decoration: InputDecoration(labelText: widget.getLocalized('gender')),
                  ),
                  const SizedBox(height: 24),
                  Text(widget.getLocalized('add_reminder'), style: Theme.of(context).textTheme.titleMedium),
                  TextFormField(
                    decoration: InputDecoration(labelText: widget.getLocalized('title')),
                    onChanged: (value) => _title = value,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      _selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      setState(() {});
                    },
                    child: Text(_selectedDate == null
                        ? widget.getLocalized('date')
                        : DateFormat.yMd(widget.locale).format(_selectedDate!)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_title.isNotEmpty && _selectedDate != null) {
                        widget.addReminder(Reminder(title: _title, date: _selectedDate!, completed: false));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.getLocalized('save'))));
                      }
                    },
                    child: Text(widget.getLocalized('save')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: widget.toggleLanguage,
              child: Text(widget.getLocalized('switch_lang')),
            ),
          ],
        ),
      ),
    );
  }
}