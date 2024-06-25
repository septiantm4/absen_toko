import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EntryFormAbsentScreen extends StatefulWidget {
  const EntryFormAbsentScreen({Key? key}) : super(key: key);

  @override
  _EntryFormAbsentScreenState createState() => _EntryFormAbsentScreenState();
}

class _EntryFormAbsentScreenState extends State<EntryFormAbsentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  String? _selectedEmployeeID;
  String? _selectedEmployeeName;
  String? _selectedShiftOption;
  DateTime? _selectedDate;
  bool _isLoading = false;
  final Map<String, String> _shiftOption = {
    'Shift 1': '07:00-15:00',
    'Shift 2': '15:00-22:00',
  };

  Future<List<Map<String, dynamic>>> _fetchEmployees() async {
    List<Map<String, dynamic>> employees = [];
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('employees').get();
    querySnapshot.docs.forEach((doc) {
      employees.add({
        'employeeID': doc['employeeID'],
        'name': '${doc['first_name']} ${doc['last_name']}'
      });
    });
    return employees;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Insert the data into the 'absent' collection
        await FirebaseFirestore.instance.collection('absent').add({
          'employeeID': _selectedEmployeeID,
          'employeeName': _selectedEmployeeName,
          'shift': _selectedShiftOption,
          'date': _selectedDate,
          'reason': _reasonController.text,
        });

        // Ensure all necessary values are properly set before showing the dialog
        final employeeID = _selectedEmployeeID ?? 'N/A';
        final employeeName = _selectedEmployeeName ?? 'N/A';
        final shift = _selectedShiftOption ?? 'N/A';
        final date = _selectedDate != null
            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
            : 'N/A';

        // Show popup confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Absent Entry Added'),
              content: Text(
                  'Absent entry has been successfully added for employee ID: $employeeID - $employeeName\nShift: $shift\nDate: $date'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );

        // Clear all fields after successful submission
        setState(() {
          _selectedEmployeeID = null;
          _selectedEmployeeName = null;
          _selectedShiftOption = null;
          _selectedDate = null;
          _reasonController.clear();
          _isLoading = false;
        });
      } catch (e) {
        print('Error adding document: $e');
        // Handle error as needed
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Form Absent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchEmployees(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedEmployeeID,
                      decoration: const InputDecoration(
                        labelText: 'Select Employee ID',
                        border: OutlineInputBorder(),
                      ),
                      items: snapshot.data!.map((employee) {
                        return DropdownMenuItem<String>(
                          value: employee['employeeID'],
                          child: Text(
                              '${employee['employeeID']} - ${employee['name']}'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEmployeeID = newValue;
                          _selectedEmployeeName = snapshot.data!.firstWhere(
                              (employee) =>
                                  employee['employeeID'] == newValue)['name'];
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please select an employee ID';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Shift',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedShiftOption,
                  items: _shiftOption.keys
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text('$option (${_shiftOption[option]!})'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedShiftOption = value;
                    });
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please select a shift';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                          text: _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : ''),
                      decoration: const InputDecoration(
                        labelText: 'Date of Absence',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (_selectedDate == null) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Absence',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please enter a reason for absence';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          height: 50,
                          width: 400,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            onPressed: _submitForm,
                            child: const Text(
                              'Submit',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
