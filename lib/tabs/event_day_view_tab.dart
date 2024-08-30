import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EventDayViewTab extends StatelessWidget {
  const EventDayViewTab({
    Key? key,
    required this.events,
  }) : super(key: key);
  final List<DayEvent<String>> events;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CalendarDayView.eventOnly(
      events: events,
      showHourly: true,
      eventDayViewItemBuilder: (context, index, event) {
        return HookBuilder(builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 26, 26, 26),
              // color: index % 2 == 0
              //     ? colorScheme.tertiaryContainer
              //     : colorScheme.secondaryContainer,
              border: Border.all(color: colorScheme.tertiary, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            height: 50,
            child: Center(
              child: Text(
                "${event.value}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
