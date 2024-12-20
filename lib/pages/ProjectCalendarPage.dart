import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/project.dart';
import 'labor_report_cart_screen.dart'; // Import CartPage

class ProjectCalendarPage extends StatefulWidget {
  final Project project;

  const ProjectCalendarPage({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  _ProjectCalendarPageState createState() => _ProjectCalendarPageState();
}

class _ProjectCalendarPageState extends State<ProjectCalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _projectEvents = {};

  @override
  void initState() {
    super.initState();
    _loadProjectEvents();
  }

  void _loadProjectEvents() {
    _projectEvents = {
      DateTime.now(): ['Site Inspection', 'Meeting with client'],
      DateTime.now().add(const Duration(days: 1)): ['Material delivery'],
    };
  }

  List<String> _getEventsForDay(DateTime day) {
    return _projectEvents[day] ?? [];
  }

  void _navigateToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          laborToProjectList: [], // Replace with actual data
          projectName: widget.project.projectName,
          selectedDate: _selectedDay,
          projectId: widget.project.id, // Use project ID
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Project Calendar: ${widget.project.projectName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black, // Set the background color to black
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Expanded(
              child: Container(
                color: Colors.black, // Black background for the date picker
                padding: const EdgeInsets.all(16.0),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.white, // Set date, month, year text to white
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDay,
                    minimumDate: DateTime(2020, 1, 1), // Start date
                    maximumDate: DateTime.now(), // Up to today
                    onDateTimeChanged: (DateTime date) {
                      setState(() {
                        _selectedDay = date;
                        _focusedDay = date;
                      });
                    },
                    backgroundColor: Colors.black, // Set date picker background to black
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _navigateToCartPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
