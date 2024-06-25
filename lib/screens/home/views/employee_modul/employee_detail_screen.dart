import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final DocumentSnapshot employeeDoc;

  const EmployeeDetailsScreen({super.key, required this.employeeDoc});

  @override
  Widget build(BuildContext context) {
    var employeeID = employeeDoc['employeeID'];
    var firstName = employeeDoc['first_name'];
    var lastName = employeeDoc['last_name'];
    var dateOfBirth = (employeeDoc['date_of_birth'] as Timestamp).toDate();
    var email = employeeDoc['email'];
    var phoneNumber = employeeDoc['phone_number'];
    var streetAddress = employeeDoc['street_address'];
    var city = employeeDoc['city'];
    var state = employeeDoc['state'];
    var zipCode = employeeDoc['zip_code'];
    var position = employeeDoc['position'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
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
              Text('Name: $firstName $lastName',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                  'Date of Birth: ${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Email: $email', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Phone Number: $phoneNumber',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Address: $streetAddress, $city, $state, $zipCode',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Position: $position', style: const TextStyle(fontSize: 18)),
              // Add more fields and UI components as needed
            ],
          ),
        ),
      ),
    );
  }
}
