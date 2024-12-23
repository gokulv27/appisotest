import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/workday.dart';
import '../../models/labor_to_project.dart';
import '../../models/work_day_model.dart';
import 'Fill_Shift_Widget.dart';

void shiftDialog(BuildContext context, int projectId, String projectName, DateTime selectedDate) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      int selectedValue = 1;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Fill the Shift Manual',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 10),
                RadioListTile<int>(
                  value: 1,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedValue = value);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FillShiftWidget(
                            projectId: projectId,
                            projectName: projectName,
                            selectedDate: selectedDate,
                          ),
                        ),
                      );
                    }
                  },
                  title: const Text('Shift Manual', style: TextStyle(color: Colors.white)),
                ),
                RadioListTile<int>(
                  value: 2,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedValue = value);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FillShiftWidget(
                            projectId: projectId,
                            projectName: projectName,
                            selectedDate: selectedDate,
                          ),
                        ),
                      );
                    }
                  },
                  title: const Text('Shift 2', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class CartPage extends StatelessWidget {
  final List<LaborToProject> laborToProjectList;
  final String projectName;
  final DateTime selectedDate;
  final int projectId;

  const CartPage({
    Key? key,
    required this.laborToProjectList,
    required this.projectName,
    required this.selectedDate,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$projectName ${DateFormat('dd/MM').format(selectedDate)}',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () => shiftDialog(
              context,
              projectId,
              projectName,
              selectedDate,
            ),
          ),
        ],
      ),
      body: laborToProjectList.isNotEmpty
          ? ListView.builder(
        itemCount: laborToProjectList.length,
        itemBuilder: (context, index) {
          final labor = laborToProjectList[index];
          return Card(
            color: Colors.grey[800],
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labor.laborName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Start Date: ${labor.startDate}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (labor.endDate != null)
                          Text(
                            'End Date: ${labor.endDate}',
                            style: const TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labor.skill,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context, index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      )
          : const Center(
        child: Text(
          'Cart Is Empty',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () => _submitData(context),
          style: TextButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to remove this labor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              laborToProjectList.removeAt(index);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Labor removed from cart')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _submitData(BuildContext context) async {
    for (var labor in laborToProjectList) {
      try {
        final workDay = WorkDay(
          id: null,
          laborToProject: labor.id,
          adhocEmployee: null,
          date: DateFormat('yyyy-MM-dd').format(selectedDate),
          workType: (labor.workType ?? 'FULL').toUpperCase(),
        );

        final payload = workDay.toJson()..removeWhere((key, value) => value == null);
        print('Submitting: ${jsonEncode(payload)}');

        final response = await ApiService.createWorkDay([workDay]);

        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submitted successfully for ${labor.laborName}.')),
          );
        } else {
          throw Exception('Failed to submit ${labor.laborName}.');
        }
      } catch (e) {
        String errorMessage = 'An unexpected error occurred.';
        if (e is SocketException) {
          errorMessage = 'Network error. Please check your connection.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$errorMessage\nDetails: $e')),
        );
      }
    }
  }
}
