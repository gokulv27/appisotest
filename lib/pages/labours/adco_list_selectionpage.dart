import 'package:flutter/material.dart';
import '../../api/labor_api.dart';
import '../../api/adhoc_employee_api.dart';
import '../../models/labor.dart';
import '../../models/labor_skill.dart';

class AvailableLaborPage extends StatefulWidget {
  final int projectId;

  const AvailableLaborPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _AvailableLaborPageState createState() => _AvailableLaborPageState();
}

class _AvailableLaborPageState extends State<AvailableLaborPage> {
  List<Labor> allLabor = [];
  List<Labor> filteredLabor = []; // To hold filtered labor data
  Set<int> selectedLaborIds = {};
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController(); // Search controller
  String _searchQuery = ''; // Search query

  @override
  void initState() {
    super.initState();
    fetchLaborData();
  }

  Future<void> fetchLaborData() async {
    try {
      final laborList = await LaborApi.getLaborList();

      setState(() {
        allLabor = laborList;
        filteredLabor = laborList; // Initially, show all labor
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  void _filterLaborList(String query) {
    setState(() {
      _searchQuery = query;
      filteredLabor = allLabor.where((labor) {
        final nameMatch = labor.name.toLowerCase().contains(query.toLowerCase());
        final skillMatch =
        labor.skillName.toLowerCase().contains(query.toLowerCase());
        return nameMatch || skillMatch;
      }).toList();
    });
  }

  Future<void> assignSelectedLabor() async {
    if (selectedLaborIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No labor selected')),
      );
      return;
    }

    try {
      for (var laborId in selectedLaborIds) {
        final payload = {
          "labor": laborId,
          "project": widget.projectId,
          "hired_date": DateTime.now().toIso8601String().split('T')[0],
          "is_active": true,
        };

        await AdHocEmployeeApi.createAdHocEmployee(payload);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Labor assigned successfully')),
      );

      setState(() {
        selectedLaborIds.clear();
      });
      fetchLaborData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning labor: $e')),
      );
    }
  }

  Widget _buildLaborCard(Labor labor, bool isSelected, Function(bool?) onChanged) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      child: Text(
                        labor.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 4.0),
                  child: Text(
                    labor.skillName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: onChanged,
                  activeColor: Colors.green,
                ),
              ],
            ),
            Text(
              'Daily Wages: ${labor.dailyWages}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Available Labor',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterLaborList(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by Name or Skill',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredLabor.isEmpty
                ? const Center(
              child: Text('No labor found'),
            )
                : ListView.builder(
              itemCount: filteredLabor.length,
              itemBuilder: (context, index) {
                final labor = filteredLabor[index];
                return _buildLaborCard(
                  labor,
                  selectedLaborIds.contains(labor.id),
                      (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedLaborIds.add(labor.id);
                      } else {
                        selectedLaborIds.remove(labor.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: assignSelectedLabor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
