import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/labor.dart';
import '../models/labor_skill.dart';
import '../api/labor_api.dart';

class AddLaborPage extends StatefulWidget {
  final Labor? labor;

  const AddLaborPage({Key? key, this.labor}) : super(key: key);

  @override
  _AddLaborPageState createState() => _AddLaborPageState();
}

class _AddLaborPageState extends State<AddLaborPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _dailyWagesController = TextEditingController();
  String? _selectedState;
  LaborSkill? _selectedSkill;
  List<LaborSkill> _skills = [];
  bool _isLoading = true;

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan',
    'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh',
    'Uttarakhand', 'West Bengal', 'Andaman and Nicobar Islands', 'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Jammu and Kashmir',
    'Ladakh', 'Lakshadweep', 'Puducherry',
  ];

  @override
  void initState() {
    super.initState();
    _loadSkills();
    if (widget.labor != null) {
      _nameController.text = widget.labor!.name;
      _phoneController.text = widget.labor!.phoneNo;
      _aadharController.text = widget.labor!.aadharNo;
      _emergencyContactController.text = widget.labor!.emergencyContactNumber;
      _addressController.text = widget.labor!.address;
      _cityController.text = widget.labor!.city;
      _pincodeController.text = widget.labor!.pincode;
      _dailyWagesController.text = widget.labor!.dailyWages.toString();
      _selectedState = widget.labor!.state;
    }
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);
    try {
      final skills = await LaborApi.getSkills();
      setState(() {
        _skills = skills;
        _isLoading = false;
        if (widget.labor != null) {
          _selectedSkill = _skills.firstWhere(
                (skill) => skill.id == widget.labor!.skillId,
            orElse: () => _skills.first,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load skills: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aadharController.dispose();
    _emergencyContactController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _dailyWagesController.dispose();
    super.dispose();
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final labor = Labor(
        id: widget.labor?.id ?? 0,
        name: _nameController.text,
        phoneNo: _phoneController.text,
        skillId: _selectedSkill?.id ?? 0,
        skillName: _selectedSkill?.name ?? 'Unknown',
        aadharNo: _aadharController.text,
        emergencyContactNumber: _emergencyContactController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _selectedState ?? 'Unknown',
        pincode: _pincodeController.text,
        dailyWages: double.tryParse(_dailyWagesController.text) ?? 0.0,
        createdAt: widget.labor?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.labor != null) {
        await LaborApi.updateLabor(labor);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labor updated successfully!')),
        );
      } else {
        await LaborApi.createLabor(labor);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labor added successfully!')),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save labor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.labor != null ? 'Edit Labor' : 'Add Labor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Container(
            color: Colors.black,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._buildFormFields(),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  widget.labor != null ? 'Update' : 'Add',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final fields = [
      _buildField('Name', _nameController),
      _buildField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
      _buildField('Aadhar Number', _aadharController),
      _buildField('Emergency Contact', _emergencyContactController, keyboardType: TextInputType.phone),
      _buildField('Address', _addressController),
      _buildField('City', _cityController),
      _buildField('Pincode', _pincodeController, keyboardType: TextInputType.number),
      DropdownButtonFormField<String>(
        value: _selectedState,
        hint: Text('Select State', style: TextStyle(color: Colors.grey[400])),
        onChanged: (String? newValue) => setState(() => _selectedState = newValue),
        items: _states.map((state) => DropdownMenuItem(
          value: state,
          child: Text(state, style: const TextStyle(color: Colors.white)),
        )).toList(),
        decoration: _getInputDecoration('State'),
        dropdownColor: Colors.black,
        style: const TextStyle(color: Colors.white),
      ),
      DropdownButtonFormField<LaborSkill>(
        value: _selectedSkill,
        hint: Text('Select Skill', style: TextStyle(color: Colors.grey[400])),
        onChanged: (LaborSkill? newValue) => setState(() => _selectedSkill = newValue),
        items: _skills.map((skill) => DropdownMenuItem(
          value: skill,
          child: Text(skill.name, style: const TextStyle(color: Colors.white)),
        )).toList(),
        decoration: _getInputDecoration('Skill'),
        dropdownColor: Colors.black,
        style: const TextStyle(color: Colors.white),
      ),
      _buildField('Daily Wages', _dailyWagesController, keyboardType: TextInputType.number),
    ];

    return fields
        .asMap()
        .entries
        .map((e) => FadeInUp(
      duration: Duration(milliseconds: 400 + e.key * 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: e.value,
      ),
    ))
        .toList();
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _getInputDecoration(label),
      style: const TextStyle(color: Colors.white),
      validator: (value) => value?.isEmpty == true ? 'Please enter $label' : null,
    );
  }
}

