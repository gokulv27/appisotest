import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CopyFormPage extends StatefulWidget {
  @override
  _CopyFormPageState createState() => _CopyFormPageState();
}

class _CopyFormPageState extends State<CopyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _dailyWagesController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<Map<String, String>> _savedData = [];
  String? _selectedRecord;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('temporaryEmployees');
    if (jsonData != null) {
      setState(() {
        _savedData = List<Map<String, String>>.from(jsonDecode(jsonData));
      });
    }
  }

  void _populateForm(Map<String, String> data) {
    setState(() {
      _nameController.text = data['name']!;
      _skillController.text = data['skill']!;
      _dailyWagesController.text = data['dailyWages']!;
      _startDateController.text = data['startDate']!;
      _endDateController.text = data['endDate'] ?? '';
    });
  }

  void _onRecordSelected(String? selected) {
    setState(() {
      _selectedRecord = selected;
    });
    if (selected != null) {
      Map<String, String> data =
      _savedData.firstWhere((record) => record['name'] == selected);
      _populateForm(data);
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      // Add the new record to saved data
      Map<String, String> newData = {
        'name': _nameController.text,
        'skill': _skillController.text,
        'dailyWages': _dailyWagesController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      _savedData.add(newData);
      prefs.setString('temporaryEmployees', jsonEncode(_savedData));

      // Clear the form and notify the user
      _formKey.currentState!.reset();
      _nameController.clear();
      _skillController.clear();
      _dailyWagesController.clear();
      _startDateController.clear();
      _endDateController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copy Form'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedRecord,
              hint: const Text('Select a Record to Copy'),
              isExpanded: true,
              items: _savedData
                  .map((record) => DropdownMenuItem(
                value: record['name'],
                child: Text(record['name']!),
              ))
                  .toList(),
              onChanged: _onRecordSelected,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Employee Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      labelText: 'Skill',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a skill';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dailyWagesController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Wages',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter daily wages';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                      labelText: 'Start Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a start date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                      labelText: 'End Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                      'Save Record',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
