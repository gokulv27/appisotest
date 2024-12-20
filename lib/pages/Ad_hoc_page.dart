import 'package:flutter/material.dart';

class AdHocEmployeePage extends StatefulWidget {
  @override
  _AdHocEmployeePageState createState() => _AdHocEmployeePageState();
}

class _AdHocEmployeePageState extends State<AdHocEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _dailyWagesController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<Map<String, String>> _temporaryEmployees = [];

  void _addAdHocEmployee() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _temporaryEmployees.add({
          'name': _nameController.text,
          'skill': _skillController.text,
          'dailyWages': _dailyWagesController.text,
          'startDate': _startDateController.text,
          'endDate': _endDateController.text,
        });
      });

      // Clear the form fields
      _nameController.clear();
      _skillController.clear();
      _dailyWagesController.clear();
      _startDateController.clear();
      _endDateController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Hoc Employees'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                    onPressed: _addAdHocEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                      'Add Employee',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Temporary Employees',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _temporaryEmployees.length,
                itemBuilder: (context, index) {
                  final employee = _temporaryEmployees[index];
                  return Card(
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        employee['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Skill: ${employee['skill']}\n'
                            'Daily Wages: ${employee['dailyWages']}\n'
                            'Start Date: ${employee['startDate']}\n'
                            'End Date: ${employee['endDate'] ?? 'N/A'}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
