import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FakeChatScreen extends StatefulWidget {
  @override
  _FakeChatScreenState createState() => _FakeChatScreenState();
}

class _FakeChatScreenState extends State<FakeChatScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () { // Double-tap to switch back to the real chat
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Office Calendar')),
        body: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: const [
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text("📅 Team Meeting"),
                    subtitle: Text("Monday, 10 AM - Conference Room"),
                  ),
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text("📅 Client Presentation"),
                    subtitle: Text("Wednesday, 3 PM - Zoom Call"),
                  ),
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text("📅 Project Deadline"),
                    subtitle: Text("Friday, 5 PM - Submit Report"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}