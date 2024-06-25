import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:absen_toko/screens/home/views/employee_modul/employee_detail_screen.dart';
import 'package:absen_toko/screens/home/views/employee_modul/employee_edit_screen.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({Key? key}) : super(key: key);

  @override
  _EmployeesListScreenState createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  late Stream<QuerySnapshot> _employeeStream;
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _employees = [];

  @override
  void initState() {
    super.initState();
    _employeeStream =
        FirebaseFirestore.instance.collection('employees').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _onSearchTextChanged,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _employeeStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }

                _employees = snapshot.data!.docs.toList();

                // Apply search filter
                if (_searchController.text.isNotEmpty) {
                  _employees = _employees.where((employee) {
                    String fullName =
                        '${employee['first_name']} ${employee['last_name']}';
                    return fullName
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                  }).toList();
                }

                return _employees.isEmpty
                    ? const Center(child: Text('No employees found.'))
                    : ListView.builder(
                        itemCount: _employees.length,
                        itemBuilder: (BuildContext context, int index) {
                          var doc = _employees[index];
                          var employeeID = doc['employeeID'];
                          var firstName = doc['first_name'];
                          var lastName = doc['last_name'];
                          var position = doc['position'];
                          var phoneNumber = doc['phone_number'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8.0),
                              child: InkWell(
                                onTap: () {
                                  _navigateToEmployeeDetails(context, doc);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$employeeID - $firstName $lastName',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$position',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Phone: $phoneNumber',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        iconSize: 30,
                                        icon: const Icon(
                                          Icons.edit_note_outlined,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          _navigateToEditEmployee(context, doc);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEmployeeDetails(
      BuildContext context, DocumentSnapshot employeeDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailsScreen(employeeDoc: employeeDoc),
      ),
    );
  }

  void _navigateToEditEmployee(
      BuildContext context, DocumentSnapshot employeeDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEmployeeScreen(employeeDoc: employeeDoc),
      ),
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {}); // Trigger rebuild on text change
  }
}
