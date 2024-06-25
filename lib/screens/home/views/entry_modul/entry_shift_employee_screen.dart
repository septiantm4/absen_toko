import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EntryFormShiftScreen extends StatefulWidget {
  const EntryFormShiftScreen({Key? key}) : super(key: key);

  @override
  _EntryFormShiftScreenState createState() => _EntryFormShiftScreenState();
}

class _EntryFormShiftScreenState extends State<EntryFormShiftScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedEmployeeID;
  String? _selectedEmployeeName;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _fetchAvailableEmployees() async {
    List<Map<String, dynamic>> employees = [];
    List<String> assignedEmployeeIDs = [];

    // Fetch all employees
    QuerySnapshot employeeSnapshot =
        await FirebaseFirestore.instance.collection('employees').get();
    employeeSnapshot.docs.forEach((doc) {
      employees.add({
        'employeeID': doc['employeeID'],
        'name': '${doc['first_name']} ${doc['last_name']}'
      });
    });

    // Fetch assigned employee IDs
    QuerySnapshot shiftSnapshot =
        await FirebaseFirestore.instance.collection('employee_shift').get();
    shiftSnapshot.docs.forEach((doc) {
      assignedEmployeeIDs.add(doc['employeeID']);
    });

    // Filter out assigned employees
    employees = employees
        .where(
            (employee) => !assignedEmployeeIDs.contains(employee['employeeID']))
        .toList();

    return employees;
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartDate
            ? (_startDate ?? DateTime.now())
            : (_endDate ?? DateTime.now())),
      );
      if (pickedTime != null) {
        setState(() {
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartDate) {
            _startDate = selectedDateTime;
          } else {
            _endDate = selectedDateTime;
          }
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('employee_shift').add({
          'employeeID': _selectedEmployeeID,
          'employeeName': _selectedEmployeeName,
          'startDate': _startDate,
          'endDate': _endDate,
        });

        final employeeID = _selectedEmployeeID;
        final employeeName = _selectedEmployeeName;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Shift Entry Added'),
              content: Text(
                  'Shift entry has been successfully added for employee ID: $employeeID - $employeeName'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        setState(() {
          _selectedEmployeeID = null;
          _selectedEmployeeName = null;
          _startDate = null;
          _endDate = null;
          _isLoading = false;
        });
      } catch (e) {
        print('Error adding document: $e');
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
        title: const Text('Entry Form Shift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_selectedEmployeeID == null)
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchAvailableEmployees(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
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
                if (_selectedEmployeeID != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Selected Employee: $_selectedEmployeeID - $_selectedEmployeeName',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDateTime(context, true),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _startDate != null
                        ? DateFormat('dd-MM-yyyy:HH:mm').format(_startDate!)
                        : '',
                  ),
                  validator: (val) {
                    if (_startDate == null) {
                      return 'Please select a start date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDateTime(context, false),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _endDate != null
                        ? DateFormat('dd-MM-yyyy:HH:mm').format(_endDate!)
                        : '',
                  ),
                  validator: (val) {
                    if (_endDate == null) {
                      return 'Please select an end date';
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
