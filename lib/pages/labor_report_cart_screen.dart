import 'dart:convert';
import 'dart:io'; // Add this for SocketException
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/Cart_page_api.dart';
import '../models/labor_to_project.dart';
import 'package:intl/intl.dart';
import '../models/labor.dart';
import '../models/workday_model.dart';
import 'Fill_Shift_Widget.dart';


void shiftDialog(BuildContext context, int projectId, String projectName, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900], // Set the grey background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int selectedValue = 1; // Initial selected value

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
              ListView(
                shrinkWrap: true,
                children: [
                  RadioListTile<int>(
                    value: 1,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      if (value != null) {
                        selectedValue = value;
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FillShiftWidget(
                              projectId: projectId, // Pass the projectId
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
                        selectedValue = value;
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FillShiftWidget(
                              projectId: projectId, // Pass the projectId
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
            ],
          ),
        );
      },
    );
  }




  class CartPage extends StatelessWidget {
    final List<LaborToProject> laborToProjectList;
    final String projectName;
    final DateTime selectedDate;
    final int projectId; // Add projectId to CartPage

    const CartPage({
      Key? key,
      required this.laborToProjectList,
      required this.projectName,
      required this.selectedDate,
      required this.projectId, // Initialize projectId
    }) : super(key: key);
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('$projectName ${ DateFormat('dd/MM').format(selectedDate)}',
          style: TextStyle(fontSize: 20,color: Colors.white),),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: Icon(Icons.list, color: Colors.white),
              onPressed: () => shiftDialog(context,
                projectId,
                projectName,
                selectedDate,),
            ),
          ],
        ),
        body: laborToProjectList.isNotEmpty
            ? ListView.builder(
          itemCount: laborToProjectList.length,
          itemBuilder: (context, index) {
            final labor = laborToProjectList[index];
            return Card(
              color: Colors.grey[800], // Set the card background color to dark grey
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Add padding for better layout
                child: Row(
                  children: [



                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                           ' ${labor.laborName}',
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
                            style: const TextStyle(color: Colors.white,),
                          ),
                        ],
                      ),
                    ),
                    // Delete Icon
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

          })
            : const Center(
          child: Text('Cart Is Empty',style: TextStyle(color: Colors.white,fontSize: 18),),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton(
            onPressed: () {
              _submitData(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green, // Set the background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Optional: Add rounded corners
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16), // Set text color
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
                laborToProjectList.removeAt(index); // Handle deletion
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
      final workDayData = laborToProjectList.map((labor) {
        return {
          'labor_to_project': labor.id, // Labor ID
          'date': DateFormat('yyyy-MM-dd').format(selectedDate), // Formatted date
          'work_type': labor.workType ?? 'FULL', // Default to 'FULL' if not specified
        };
      }).toList();

      try {
        final response = await ApiService.createWorkDay(workDayData, projectId);

        if (response != null && response['id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data submitted successfully: ${response['id']}')),
          );
          Navigator.pop(context); // Navigate back after successful submission
        } else {
          throw Exception('Invalid response from server');
        }
      } catch (e) {
        String errorMessage = 'Error submitting data';
        if (e is SocketException) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e is FormatException) {
          errorMessage = 'Data format error. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$errorMessage: $e')),
        );
      }
    }





  }

