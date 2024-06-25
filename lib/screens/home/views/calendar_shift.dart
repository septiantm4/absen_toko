import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarShift extends StatefulWidget {
  const CalendarShift({Key? key}) : super(key: key);

  @override
  State<CalendarShift> createState() => _CalendarShiftState();
}

class _CalendarShiftState extends State<CalendarShift> {
  late List<Appointment> _shiftAppointments = []; // Initialize as empty list

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
          subject: '${doc['employeeName']} Shift',
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
        body: Container(
          child: SfCalendar(
            view: CalendarView.month,
            monthViewSettings: const MonthViewSettings(
              dayFormat:
                  'EEE', // Display abbreviated day names (e.g., Mon, Tue)
              numberOfWeeksInView: 4, // Display 4 weeks in the month view
              appointmentDisplayMode: MonthAppointmentDisplayMode
                  .appointment, // Display appointments directly on calendar days
              showAgenda: true, // Enable agenda view
              appointmentDisplayCount:
                  2, // Display up to 2 appointments per day
              navigationDirection: MonthNavigationDirection
                  .horizontal, // Navigate horizontally in month view
            ),
            dataSource: _getCalendarDataSource(),
          ),
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
