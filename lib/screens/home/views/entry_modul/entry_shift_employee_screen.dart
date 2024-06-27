import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntryFormShiftScreen extends StatefulWidget {
  const EntryFormShiftScreen({Key? key}) : super(key: key);

  @override
  _EntryFormShiftScreenState createState() => _EntryFormShiftScreenState();
}

class _EntryFormShiftScreenState extends State<EntryFormShiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController textEditingController = TextEditingController();

  String? _selectedEmployeeID;
  String? _selectedEmployeeName;
  String? _selectedEmployeeDetails; // Additional details if needed
  String? _selectedShiftType; // Selected shift type
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;

  List<String> _shiftTypes = []; // List to store shift types

  @override
  void initState() {
    super.initState();
    _fetchShiftTypes(); // Fetch shift types on init
  }

  Future<void> _fetchShiftTypes() async {
    try {
      QuerySnapshot shiftSnapshot =
          await FirebaseFirestore.instance.collection('shift').get();
      List<String> shiftTypes = shiftSnapshot.docs.map((doc) {
        return doc['shift_name'] as String;
      }).toList();

      setState(() {
        _shiftTypes = shiftTypes;
      });

      print('Fetched shift types: $_shiftTypes'); // Debug print
    } catch (e) {
      print('Error fetching shift types: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAvailableEmployees() async {
    List<Map<String, dynamic>> employees = [];

    // Fetch all employees
    QuerySnapshot employeeSnapshot =
        await FirebaseFirestore.instance.collection('employees').get();
    employeeSnapshot.docs.forEach((doc) {
      employees.add({
        'employeeID': doc['employeeID'],
        'name': '${doc['first_name']} ${doc['last_name']}',
        // Add other details if needed
      });
    });

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
      setState(() {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );
        if (isStartDate) {
          _startDate = selectedDateTime;
        } else {
          _endDate = selectedDateTime;
        }
      });
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
          'shiftType': _selectedShiftType, // Save selected shift type
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
          _selectedEmployeeDetails = null;
          _selectedShiftType = null; // Reset shift type
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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchAvailableEmployees(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors
                                .grey), // Adjust color and other properties as needed
                        borderRadius: BorderRadius.circular(
                            8.0), // Adjust border radius as needed
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Employee',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: snapshot.data!.map((employee) {
                            return DropdownMenuItem<String>(
                              value: employee['employeeID'],
                              child: Text(
                                  '${employee['employeeID']} - ${employee['name']}'),
                            );
                          }).toList(),
                          value: _selectedEmployeeID,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedEmployeeID = newValue;
                              _selectedEmployeeName = snapshot.data!.firstWhere(
                                  (employee) =>
                                      employee['employeeID'] ==
                                      newValue)['name'];
                              // Set additional details if needed
                              _selectedEmployeeDetails =
                                  ''; // Example: employee['email']
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            height: 55,
                            width: 400,
                          ),
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 500,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: textEditingController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  hintText: 'Search for an Employee...',
                                  hintStyle: const TextStyle(fontSize: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (DropdownMenuItem<String> employee,
                                String searchValue) {
                              return employee.child!
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase());
                            },
                          ),
                          //This to clear the search value when you close the menu
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              textEditingController.clear();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                if (_selectedEmployeeID != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Employee: $_selectedEmployeeID - $_selectedEmployeeName',
                          style: const TextStyle(fontSize: 16),
                        ),
                        // Add additional details here if needed
                        if (_selectedEmployeeDetails != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Additional Details: $_selectedEmployeeDetails',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedShiftType,
                  decoration: const InputDecoration(
                    labelText: 'Select Shift Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _shiftTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    print('Selected shift type: $newValue'); // Debug print
                    setState(() {
                      _selectedShiftType = newValue;
                    });
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please select a shift type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDateTime(context, true),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _startDate != null
                        ? DateFormat('dd-MM-yyyy').format(_startDate!)
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
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDateTime(context, false),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _endDate != null
                        ? DateFormat('dd-MM-yyyy').format(_endDate!)
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
