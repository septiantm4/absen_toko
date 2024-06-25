import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  String? userName;

  @override
  void initState() {
    super.initState();
    // Get the current user from FirebaseAuth
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch the user data from Firestore
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    setState(() {
      userName = userDoc['name']; // Assuming the user's name field is 'name'
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Change Password',
        'icon': Icons.lock,
        'route': '/change-password',
      },
      {
        'title': 'Entry Form Employee',
        'icon': Icons.person_add,
        'route': '/entry-form-employee',
      },
      {
        'title': 'Entry Shift Employee',
        'icon': Icons.schedule,
        'route': '/entry-shift-employee',
      },
      {
        'title': 'Entry Form Absent',
        'icon': Icons.assignment_late,
        'route': '/entry-form-absent',
      },
      {
        'title': 'Employee Shift List',
        'icon': Icons.list,
        'route': '/employee-shift-list',
      },
      {
        'title': 'Employee List',
        'icon': Icons.people,
        'route': '/employee-list',
      },
      {
        'title': 'Calendar Shift',
        'icon': Icons.calendar_month,
        'route': '/calendar-shift',
      },
    ];

    final List<Map<String, dynamic>> gridItems = menuItems.where((item) {
      return item['title'] == 'Employee Shift List' ||
          item['title'] == 'Employee List' ||
          item['title'] == 'Calendar Shift';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage('assets/profile.png'), // Correct asset path
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Welcome, ${userName ?? 'User'}!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ...menuItems.map((item) {
              return ListTile(
                leading: Icon(item['icon']),
                title: Text(item['title']),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.pushNamed(context, item['route']);
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 1.0,
          ),
          itemCount: gridItems.length,
          itemBuilder: (context, index) {
            final item = gridItems[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, item['route']);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(3, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
