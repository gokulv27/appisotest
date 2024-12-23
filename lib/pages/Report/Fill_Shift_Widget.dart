import 'package:flutter/material.dart';
import '../../api/labor_to_project_api.dart';
import '../../models/labor_to_project.dart';
import 'labor_report_cart_screen.dart';

class FillShiftWidget extends StatefulWidget {
  final int projectId;
  final String projectName;
  final DateTime selectedDate;

  const FillShiftWidget({
    Key? key,
    required this.projectId,
    required this.projectName,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _FillShiftWidgetState createState() => _FillShiftWidgetState();
}

class _FillShiftWidgetState extends State<FillShiftWidget> {
  List<LaborToProject> laborList = [];
  bool isLoading = true;
  final LaborToProjectApi laborToProjectApi = LaborToProjectApi();

  @override
  void initState() {
    super.initState();
    _fetchLaborData();
  }

  Future<void> _fetchLaborData() async {
    try {
      final laborData = await laborToProjectApi.getLaborForProject(widget.projectId);
      setState(() {
        laborList = laborData
            .map((labor) => labor.copyWith(isDeleted: false, workType: 'Full Day'))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error fetching labor data: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fill Shift',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: laborList.length,
              itemBuilder: (context, index) {
                final labor = laborList[index];
                return _buildLaborItem(labor);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _onAddToCart,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _onAddToCart() {
    final selectedLabors = laborList.where((labor) => !labor.isDeleted).toList();

    if (selectedLabors.isEmpty) {
      _showSnackBar('Please select at least one labor.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          laborToProjectList: selectedLabors,
          projectName: widget.projectName,
          selectedDate: widget.selectedDate,
          projectId: widget.projectId,
        ),
      ),
    );
  }

  Widget _buildLaborItem(LaborToProject labor) {
    return Card(
      color: labor.isDeleted ? Colors.grey[900] : Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        labor.laborName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        labor.skill,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildWorkTypeButtons(labor),
                IconButton(
                  icon: Icon(
                    labor.isDeleted ? Icons.add_circle_sharp : Icons.delete,
                    color: labor.isDeleted ? Colors.green : Colors.red,
                  ),
                  onPressed: () => _toggleLaborDeletion(labor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkTypeButtons(LaborToProject labor) {
    return Row(
      children: [
        _buildActionButton(
          label: 'Full Day',
          isSelected: labor.workType == 'Full Day',
          onTap: () => _updateLaborWorkType(labor, 'Full Day'),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          label: 'Half Day',
          isSelected: labor.workType == 'Half Day',
          onTap: () => _updateLaborWorkType(labor, 'Half Day'),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          label: 'Overtime',
          isSelected: labor.workType == 'Overtime',
          onTap: () => _updateLaborWorkType(labor, 'Overtime'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey,
        minimumSize: const Size(72, 15),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _toggleLaborDeletion(LaborToProject labor) {
    setState(() {
      laborList = laborList.map((l) {
        if (l.id == labor.id) {
          return l.copyWith(
            isDeleted: !labor.isDeleted,
            workType: labor.isDeleted ? 'Full Day' : null,
          );
        }
        return l;
      }).toList();
    });
  }

  void _updateLaborWorkType(LaborToProject labor, String workType) {
    if (!labor.isDeleted) {
      setState(() {
        laborList = laborList.map((l) {
          if (l.id == labor.id) {
            return l.copyWith(workType: workType);
          }
          return l;
        }).toList();
      });
    }
  }
}
