import 'package:flutter/material.dart';
import '../models/project.dart';
import '../api/project_api.dart';
import '../widget/drawer_widget.dart';
import 'ProjectCalendarPage.dart';

class ReportProjectListPage extends StatefulWidget {
  const ReportProjectListPage({Key? key}) : super(key: key);

  @override
  _ReportProjectListPageState createState() => _ReportProjectListPageState();
}

class _ReportProjectListPageState extends State<ReportProjectListPage> {
  late List<Project> _projects;
  late List<Project> _filteredProjects;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    setState(() => _isLoading = true);
    await _fetchProjects();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchProjects() async {
    try {
      final projectList = await ProjectApi.getProjectList();
      setState(() {
        _projects = projectList;
        _filteredProjects = projectList;
      });
    } catch (e) {
      print('Error fetching projects: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load projects: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterProjects(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProjects = _projects;
      } else {
        _filteredProjects = _projects.where((project) {
          final projectName = project.projectName.toLowerCase();
          final clientName = project.clientName.toLowerCase();
          return projectName.contains(lowerQuery) || clientName.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project List',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      drawer: const DrawerWidget(),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProjects,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search projects or clients',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
                  : _filteredProjects.isEmpty
                  ? const Center(
                child: Text(
                  'No projects found',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = _filteredProjects[index];
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectCalendarPage(
                              project: project,
                              // Pass projectId
                            ),
                          ),
                        );
                      },
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.projectName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: project.activeStatus
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.activeStatus
                                  ? 'Active'
                                  : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client: ${project.clientName}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Budget: ₹${project.budget.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Location: ${project.location}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
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
