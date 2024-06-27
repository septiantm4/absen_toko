import 'package:absen_toko/screens/home/views/entry_modul/entry_shift_employee_screen.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarShift extends StatefulWidget {
  const CalendarShift({Key? key}) : super(key: key);

  @override
  State<CalendarShift> createState() => _CalendarShiftState();
}

class _CalendarShiftState extends State<CalendarShift> {
  late List<Appointment> _shiftAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadShiftAppointments();
  }

  Future<void> _loadShiftAppointments() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('employee_shift').get();

      final List<Appointment> appointments = querySnapshot.docs.map((doc) {
        final DateTime startDate = (doc['startDate'] as Timestamp).toDate();
        final DateTime endDate = (doc['endDate'] as Timestamp).toDate();

        return Appointment(
          startTime: startDate,
          endTime: endDate,
          subject: '${doc['employeeName']} - ${doc['shiftType']}',
          color: Colors.blue,
          startTimeZone: '',
          endTimeZone: '',
        );
      }).toList();

      setState(() {
        _shiftAppointments = appointments;
      });
    } catch (e) {
      print('Error fetching shift data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Shift Calendar'),
        ),
        body: SfCalendar(
          view: CalendarView.month,
          monthViewSettings: const MonthViewSettings(
            dayFormat: 'EEE', // Display abbreviated day names (e.g., Mon, Tue)
            numberOfWeeksInView: 4, // Display 4 weeks in the month view
            appointmentDisplayMode: MonthAppointmentDisplayMode
                .appointment, // Display appointments directly on calendar days
            showAgenda: true, // Enable agenda view
            appointmentDisplayCount: 2, // Display up to 2 appointments per day
            navigationDirection: MonthNavigationDirection
                .horizontal, // Navigate horizontally in month view
          ),
          dataSource: _getCalendarDataSource(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const FractionallySizedBox(
                heightFactor: 0.7,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: EntryFormShiftScreen(),
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  _DataSource _getCalendarDataSource() {
    return _DataSource(_shiftAppointments);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
