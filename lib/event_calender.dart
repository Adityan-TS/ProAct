import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:kalender/kalender.dart';
import 'package:proact/model/Event.dart';

class EventCalender extends StatefulWidget {
  final List<Map<String, String>> eventData;

  const EventCalender({super.key, required this.eventData});

  @override
  State<EventCalender> createState() => _EventCalenderState();
}

class _EventCalenderState extends State<EventCalender> {
  final CalendarController<Event> controller = CalendarController(
    calendarDateTimeRange: DateTimeRange(
      start: DateTime(DateTime.now().year - 1),
      end: DateTime(DateTime.now().year + 1),
    ),
  );
  final CalendarEventsController<Event> eventController =
      CalendarEventsController<Event>();

  late ViewConfiguration currentConfiguration = viewConfigurations[0];
  List<ViewConfiguration> viewConfigurations = [
    CustomMultiDayConfiguration(
        numberOfDays: 1,
        name: "Days",
        showDayHeader: false,
        showMultiDayHeader: false,
        timeIndicatorSnapping: false,
        showWeekNumber: false,
        enableResizing: true,
        startHour: 0,
        endHour: 24,
        verticalSnapRange: Duration(minutes: 90),
        verticalStepDuration: Duration(minutes: 90)),
    CustomMultiDayConfiguration(
      name: 'Custom',
      numberOfDays: 1,
    ),
    WeekConfiguration(
        name: "Days",
        showDayHeader: false,
        showMultiDayHeader: false,
        timeIndicatorSnapping: false,
        showWeekNumber: false,
        enableResizing: true,
        initialHeightPerMinute: 1.5,
        verticalStepDuration: Duration(minutes: 50)),
    WorkWeekConfiguration(),
    // MonthConfiguration(),
    // ScheduleConfiguration(),
    MultiWeekConfiguration(
      numberOfWeeks: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    print("event list ");
    var events = widget.eventData;

    if (events.isNotEmpty) {
      DateTime now = DateTime.now();
      for (var i = 0; i < events.length; i++) {
        String startTime = events[i]["startTime"] as String;
        var timings = startTime.split(":"); 
        int startHour =
            int.parse(timings[0]);
        int startMinutes = int.parse(timings[1].substring(0,2));

        String endTime = events[i]["endTime"] as String;
        timings = endTime.split(":");
        int endHour = int.parse(timings[0]);
        int endMinutes = int.parse(timings[1].substring(0,2));

        String title = events[i]["name"] as String;

        eventController.addEvents([
          CalendarEvent(
            dateTimeRange: DateTimeRange(
              start: DateTime(
                  now.year, now.month, now.day, startHour + 1, startMinutes),
              end: DateTime(
                  now.year, now.month, now.day, endHour + 1, endMinutes),
            ),
            eventData: Event(title: title),
          ),
        ]);

        print("starttime ${startTime} endTIme ${endTime} title ${title}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendar = CalendarView<Event>(
      controller: controller,
      eventsController: eventController,
      viewConfiguration: currentConfiguration,
      tileBuilder: _tileBuilder,
      multiDayTileBuilder: _multiDayTileBuilder,
      scheduleTileBuilder: _scheduleTileBuilder,
      components: CalendarComponents(
        timelineBuilder: _timeLineBuilder,
        calendarHeaderBuilder: _calendarHeader1,

        // dayHeaderBuilder: (date, onTapped)   {
        //   return Container(
        //     height: 20,
        //     width: 200,
        //     decoration: BoxDecoration(
        //       color: Colors.amber,
        //       borderRadius: BorderRadius.only(
        //         bottomLeft: Radius.circular(20.0),
        //         bottomRight: Radius.circular(20.0),
        //       ),
        //     ),
        //   );
        // }
      ),
      eventHandlers: CalendarEventHandlers(
        // onEventTapped: _onEventTapped,
        onEventChanged: _onEventChanged,
        onCreateEvent: _onCreateEvent,
        onEventCreated: _onEventCreated,
      ),
      style: CalendarStyle(
          hourLineStyle: HourLineStyle(color: Colors.black12, thickness: 2),
          calendarHeaderBackgroundStyle: CalendarHeaderBackgroundStyle(
              headerElevation: 2,
              headerBackgroundColor: Color.fromARGB(26, 255, 255, 255),
              headerSurfaceTintColor: Color.fromARGB(26, 255, 255, 255)),
          timeIndicatorStyle: TimeIndicatorStyle(
            circleRadius: 10,
            color: Colors.transparent,
          ),
          daySeparatorStyle: DaySeparatorStyle(color: Colors.transparent),
          timelineStyle: TimelineStyle(
            use24HourFormat: true,
            textStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.white,
          ),

    );

    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      body: Container(child: calendar),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    ));
  }

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
              MaterialPageRoute(
                  builder: (context) =>
                      EventCalender(eventData: widget.eventData)),
              // builder: (context) => CalendarPage(eventData: eventData)),
            );
            break;
        }
      },
    );
  }

  CalendarEvent<Event> _onCreateEvent(DateTimeRange dateTimeRange) {
    return CalendarEvent(
      dateTimeRange: dateTimeRange,
      eventData: Event(
        title: 'New Event',
      ),
    );
  }

  Future<void> _onEventCreated(CalendarEvent<Event> event) async {
    // Add the event to the events controller.
    eventController.addEvent(event);

    // Deselect the event.
    eventController.deselectEvent();
  }

  Future<void> _onEventTapped(
    CalendarEvent<Event> event,
  ) async {
    if (isMobile) {
      eventController.selectedEvent == event
          ? eventController.deselectEvent()
          : eventController.selectEvent(event);
    }
  }

  Future<void> _onEventChanged(
    DateTimeRange initialDateTimeRange,
    CalendarEvent<Event> event,
  ) async {
    if (isMobile) {
      eventController.deselectEvent();
    }
  }

   Widget _tileBuilder(
    CalendarEvent<Event> event,
    TileConfiguration configuration,
  ) {
    final color = event.eventData?.color ?? Colors.black;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
      elevation: configuration.tileType == TileType.ghost ? 0 : 8,
      color: configuration.tileType != TileType.ghost
          ? color
          : color.withAlpha(100),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            event.eventData?.title ?? 'New Event',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
          ),
          Text(
            '${event.start.hour - 1}:${event.start.minute} - ${event.end.hour - 1}:${event.end.minute}',
            style: TextStyle(color: Colors.white),
          ),
        ]),
    );
  }

  // Widget _tileBuilder(
  //   CalendarEvent<Event> event,
  //   TileConfiguration configuration,
  // ) {
  //   return Container(
  //       margin: EdgeInsets.only(top: 5, bottom: 5),
  //       padding: EdgeInsets.all(5),
  //       width: 200,
  //       height: 100,
  //       decoration: BoxDecoration(
  //           color: Color.fromARGB(255, 26, 26, 26),
  //           borderRadius: BorderRadius.circular(10)),
  //       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  //         Text(
  //           event.eventData?.title ?? 'New Event',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //               color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
  //         ),
  //         Text(
  //           '${event.start.hour - 1}:${event.start.minute} - ${event.end.hour - 1}:${event.end.minute}',
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ]));
  // }
  // Widget _tileBuilder(
  //   CalendarEvent<Event> event,
  //   TileConfiguration configuration,
  // ) {
  //   final color = event.eventData?.color ?? Colors.black;
  //   return Card(

  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     margin: EdgeInsets.zero,
  //     elevation: configuration.tileType == TileType.ghost ? 0 : 8,
  //     color: configuration.tileType != TileType.ghost
  //         ? color
  //         : color.withAlpha(100),
  //     child: Container(
  //       padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
  //       child: configuration.tileType != TileType.ghost
  //           ? Text(
  //               event.eventData?.title ?? 'New Event',
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 color: Colors.white,
  //               ),
  //             )
  //           : null,
  //     ),
  //   );
  // }

  Widget _multiDayTileBuilder(
    CalendarEvent<Event> event,
    MultiDayTileConfiguration configuration,
  ) {
    final color = event.eventData?.color ?? Colors.blue;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: configuration.tileType == TileType.selected ? 8 : 0,
      color: configuration.tileType == TileType.ghost
          ? color.withAlpha(100)
          : color,
      child: Center(
        child: configuration.tileType != TileType.ghost
            ? Text(event.eventData?.title ?? 'New Event')
            : null,
      ),
    );
  }

  Widget _scheduleTileBuilder(CalendarEvent<Event> event, DateTime date) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: event.eventData?.color ?? Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(event.eventData?.title ?? 'New Event'),
    );
  }

  List<String> months_name = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  Widget _dayHeaderBuilder(date, onTapped) {
    return Container(
      child: Text("Day Header"),
    );
  }

  Widget _timeLineBuilder(
    double hourHeight,
    int startHour,
    int endHour,
  ) {
    print('hourHeight ${hourHeight} startHour ${startHour} endHour ${endHour}');
    return Container(
        padding: EdgeInsets.only(bottom: 20),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: hourHeight * 24 + 100),
            child: IntrinsicHeight(
              child: Column(
                children: getHourItem(hourHeight),
              ),
            ),
          ),
        ));
  }

  List<Widget> getHourItem(double height) {
    List<String> hours = [
      "",
      "00:00",
      "01:00",
      "02:00",
      "03:00",
      "04:00",
      "05:00",
      "06:00",
      "07:00",
      "08:00",
      "09:00",
      "10:00",
      "11:00",
      "12:00",
      "13:00",
      "14:00",
      "15:00",
      "16:00",
      "17:00",
      "18:00",
      "19:00",
      "20:00",
      "21:00",
      "22:00",
      "23:00"
    ];
    int index = -1;
    return hours.map((value) {
      index++;
      return Column(children: [
        Container(
          height: index > 1 ? 7.5 : 0,
        ),
        Container(
            height: (height - 7.5),
            child: Text(
              "${value}",
              style: TextStyle(fontSize: 15, color: Colors.black26),
            )),
      ]);
    }).toList();
  }

  Widget _calendarHeader1(DateTimeRange dateTimeRange) {
    final today = DateTime.now();
    final startOfWeek =
        today.subtract(Duration(days: today.weekday - DateTime.monday));
    final daysOfWeek =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Container(
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
                textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                          color: isToday ? Colors.black : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor:
                          isToday ? Color(0xFF1A1A1A) : Colors.transparent,
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
    );
  }

  Widget _calendarHeader(DateTimeRange dateTimeRange) {
    return Container(
        padding: EdgeInsets.all(15),
        color: Colors.amber,
        alignment: Alignment.centerLeft,
        child: Text(
          '${months_name[DateTime.now().month - 1]}, ${DateTime.now().year}',
          style: TextStyle(
              color: Colors.black87, fontSize: 25, fontWeight: FontWeight.w700),
        )
        // DropdownMenu(
        //   onSelected: (value) {
        //     if (value == null) return;
        //     setState(() {
        //       currentConfiguration = value;
        //     });
        //   },
        //   initialSelection: currentConfiguration,
        //   dropdownMenuEntries: viewConfigurations
        //       .map((e) => DropdownMenuEntry(value: e, label: e.name))
        //       .toList(),
        // ),
        // IconButton.filledTonal(
        //   onPressed: controller.animateToPreviousPage,
        //   icon: const Icon(Icons.navigate_before_rounded),
        // ),
        // IconButton.filledTonal(
        //   onPressed: controller.animateToNextPage,
        //   icon: const Icon(Icons.navigate_next_rounded),
        // ),
        // IconButton.filledTonal(
        //   onPressed: () {
        //     controller.animateToDate(DateTime.now());
        //   },
        //   icon: const Icon(Icons.today),
        // ),
        );
  }

  bool get isMobile {
    return kIsWeb ? false : Platform.isAndroid || Platform.isIOS;
  }
}
