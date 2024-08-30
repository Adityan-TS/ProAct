// import 'dart:math';

import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/tabs/overflow_day_view_tab.dart';
import 'package:intl/intl.dart';

class EventCalenderNew extends HookWidget {
  final List<Map<String, String>> eventData;

  const EventCalenderNew({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    List<DayEvent<String>> dayEventsNew = [];
    if (eventData.isNotEmpty) {
      DateTime now = DateTime.now();
      for (var i = 0; i < eventData.length; i++) {
        String startTime = eventData[i]["startTime"] as String;
        var timings = startTime.split(":");
        int startHour = int.parse(timings[0]);
        int startMinutes = int.parse(timings[1].substring(0, 2));

        String endTime = eventData[i]["endTime"] as String;
        timings = endTime.split(":");
        int endHour = int.parse(timings[0]);
        int endMinutes = int.parse(timings[1].substring(0, 2));

        String title = eventData[i]["name"] as String;

        try{
        DayEvent<String> newEvent = DayEvent<String>(
          start: DateTime(
              now.year, now.month, now.day, startHour, startMinutes),
          end: DateTime(now.year, now.month, now.day, endHour, endMinutes),
          value: title,
          name: title
        );

        dayEventsNew.add(newEvent);
        }catch(e){
          print("error ${e}");
        }
        print("starttime ${startTime} endTIme ${endTime} title ${title}");
      }
    }

    useState(dayEventsNew);


    Widget _buildBottomNavigationBar(BuildContext context) {
      return BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1A1A1A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 24),
            label: '',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventCalenderNew(eventData: eventData)),
                // builder: (context) => CalendarPage(eventData: eventData)),
              );
              break;
          }
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          height: 170,
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
          color: Color.fromARGB(16, 26, 26, 26),
          child: OverflowDayViewTab(
            events: dayEventsNew,
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
    // );
  }
}


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // final Widget child;
  final double height;

  CustomAppBar({
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek =
        today.subtract(Duration(days: today.weekday - DateTime.monday));
    final daysOfWeek =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Material(
        elevation: 1,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        child: Container(
          height: preferredSize.height,
          padding: EdgeInsets.fromLTRB(16.0, 40, 16.0, 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('MMMM yyyy').format(today),
                  style: GoogleFonts.poppins(
                    textStyle:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: daysOfWeek.map((day) {
                  final isToday = day.day == today.day &&
                      day.month == today.month &&
                      day.year == today.year;
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE').format(day),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Color.fromARGB(255, 26, 26, 26),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        CircleAvatar(
                          backgroundColor:
                              isToday ? Color(0xFF1A1A1A) : Colors.transparent,
                          radius: 15,
                          child: Text(
                            day.day.toString(),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: isToday ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }
}
