import 'package:flutter/material.dart';
import '../../api/adhoc_employee_api.dart';
import '../../models/adhoc_employee.dart';
import '../../widget/project_custom_bottom_navbar.dart';
import '../document/document_page.dart';

class AdCoListPage extends StatefulWidget {
  final int projectId;

  const AdCoListPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _AdCoListPageState createState() => _AdCoListPageState();
}

class _AdCoListPageState extends State<AdCoListPage> {
  int _currentIndex = 0;
  List<AdHocEmployee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdHocEmployees();
  }

  Future<void> _fetchAdHocEmployees() async {
    try {
      final employees = await AdHocEmployeeApi.getAdHocEmployees(widget.projectId);
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildLaborCard(AdHocEmployee employee) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: Text(
                        employee.laborName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: Text(
                        employee.skill.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ),

                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: employee.isActive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    employee.isActive ? 'Active' : 'Not Active',
                    style: TextStyle(
                      color: employee.isActive ? Colors.green[800] : Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(mainAxisAlignment:MainAxisAlignment.start,children: [Text(
              'Daily Wages: ${employee.laborDailyWages}',
              style: const TextStyle(color: Colors.white70),
            ),
              const SizedBox(width: 0.9,),
              Text(
              'Hired Date: ${employee.hiredDate}',
              style: const TextStyle(color: Colors.white70),
            ),],)

          ],
        ),
      ),
    );
  }


  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentPage(projectId: widget.projectId),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdCoListPage(projectId: widget.projectId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Hoc Employees'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Handle Add Employee Action
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
          ? const Center(child: Text('No employees found'))
          : ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) => _buildLaborCard(_employees[index]),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
