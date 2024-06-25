import 'package:absen_toko/screens/home/views/calendar_shift.dart';
import 'package:absen_toko/screens/home/views/employee_modul/employe_shift_list_screen.dart';
import 'package:absen_toko/screens/home/views/employee_modul/employee_list_screen.dart';
import 'package:flutter/material.dart';

import 'package:absen_toko/screens/auth/view/welcome_screen.dart';
import 'package:absen_toko/screens/home/views/change_password_screen.dart';
import 'package:absen_toko/screens/home/views/home_screen.dart';
import 'package:absen_toko/screens/home/views/entry_modul/entry_form_employee_screen.dart';
import 'package:absen_toko/screens/home/views/entry_modul/entry_shift_employee_screen.dart';
import 'package:absen_toko/screens/home/views/entry_modul/entry_form_absen_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absen Toko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade200,
          onBackground: Colors.black,
          primary: Colors.blue,
          onPrimary: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/entry-form-employee': (context) => const EntryFormEmployeeScreen(),
        '/entry-shift-employee': (context) => const EntryFormShiftScreen(),
        '/entry-form-absent': (context) => const EntryFormAbsentScreen(),
        '/employee-shift-list': (context) => const EmployeeShiftListScreen(),
        '/employee-list': (context) => const EmployeesListScreen(),
        '/calendar-shift': (context) => const CalendarShift(),
      },
    );
  }
}

void main() {
  runApp(const MyAppView());
}
