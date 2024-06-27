import 'package:absen_toko/screens/home/views/employee_modul/employee_shift_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeShiftListScreen extends StatefulWidget {
  const EmployeeShiftListScreen({Key? key}) : super(key: key);

  @override
  _EmployeeShiftListState createState() => _EmployeeShiftListState();
}

class _EmployeeShiftListState extends State<EmployeeShiftListScreen> {
  late Stream<QuerySnapshot> _employeeShiftStream;
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allShifts = [];
  List<DocumentSnapshot> _filteredShifts = [];

  @override
  void initState() {
    super.initState();
    _employeeShiftStream =
        FirebaseFirestore.instance.collection('employee_shift').snapshots();
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      if (text.isEmpty) {
        _filteredShifts = _allShifts;
      } else {
        _filteredShifts = _allShifts.where((shift) {
          var employeeName = shift['employeeName'].toString().toLowerCase();
          return employeeName.contains(text.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToEmployeeShiftDetailScreen(
      BuildContext context, DocumentSnapshot shiftDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeShiftDetailScreen(shiftDoc: shiftDoc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Shifts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by employee name',
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
              stream: _employeeShiftStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No employee shifts found.'));
                }

                _allShifts = snapshot.data!.docs.toList();
                _filteredShifts =
                    _filteredShifts.isEmpty && _searchController.text.isEmpty
                        ? _allShifts
                        : _filteredShifts;

                return _filteredShifts.isEmpty
                    ? const Center(child: Text('No employee shifts found.'))
                    : ListView.builder(
                        itemCount: _filteredShifts.length,
                        itemBuilder: (BuildContext context, int index) {
                          var doc = _filteredShifts[index];
                          var employeeID = doc['employeeID'];
                          var shiftType = doc['shiftType'];
                          var employeeName = doc['employeeName'];
                          var startDate =
                              (doc['startDate'] as Timestamp).toDate();
                          var endDate = (doc['endDate'] as Timestamp).toDate();

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(8.0),
                              child: InkWell(
                                onTap: () {
                                  _navigateToEmployeeShiftDetailScreen(
                                      context, doc);
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
                                              '$employeeID - $employeeName',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '$shiftType',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Start Date: ${DateFormat('dd-MM-yyyy HH:mm').format(startDate)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'End Date: ${DateFormat('dd-MM-yyyy HH:mm').format(endDate)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
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
}
