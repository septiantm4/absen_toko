import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeShiftDetailScreen extends StatelessWidget {
  final DocumentSnapshot shiftDoc;

  const EmployeeShiftDetailScreen({Key? key, required this.shiftDoc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var employeeID = shiftDoc['employeeID'];
    var employeeName = shiftDoc['employeeName'];
    var startDate = (shiftDoc['startDate'] as Timestamp).toDate();
    var endDate = (shiftDoc['endDate'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Shift $employeeName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Employee ID: $employeeID',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Name: $employeeName', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Start Date: $startDate',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('End Date: $endDate', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
