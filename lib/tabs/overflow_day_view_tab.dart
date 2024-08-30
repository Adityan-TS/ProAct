import 'dart:collection';

import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final now = DateTime.now();

class OverflowDayViewTab extends HookWidget {
  const OverflowDayViewTab({
    Key? key,
    required this.events,
    this.onTimeTap,
  }) : super(key: key);
  final List<DayEvent<String>> events;
  final Function(DateTime)? onTimeTap;
  
  @override
  Widget build(BuildContext context) {
    final timeGap = useState<int>(60);
    final renderAsList = useState<bool>(true);

    final cropBottomEvents = useState<bool>(true);

    final size = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: CalendarDayView.overflow(
            // currentTimeLineColor: Colors.amber,
            onTimeTap: onTimeTap ?? print,
            timeTextStyle: TextStyle(color: Colors.black26,
              fontSize: 14
            ),
            events: UnmodifiableListView(events),
            dividerColor: Colors.black12,
            currentDate: DateTime.now(),
            timeGap: timeGap.value,
            heightPerMin: 1.5,
            startOfDay: const TimeOfDay(hour: 0, minute: 0),
            endOfDay: const TimeOfDay(hour: 24, minute: 0),
            renderRowAsListView: renderAsList.value,
            showCurrentTimeLine: true,
            cropBottomEvents: cropBottomEvents.value,
            showMoreOnRowButton: true,
            time12: false,
            overflowItemBuilder: (context, constraints, itemIndex, event) {
              return HookBuilder(builder: (context) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  key: ValueKey(event.hashCode),
                  onTap: () {
                    print(event.value);
                    print(event.start);
                    print(event.end);
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(3, 3, 3, 3),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    key: ValueKey(event.hashCode),
                    width: !renderAsList.value
                        ? (constraints.minWidth) - 6
                        : size.width / 4 - 6,
                    height: constraints.maxHeight-6,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 26, 26, 26),
                      border: Border.all(color: Colors.white24, width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: Text(
                        "${event.value}\n${event.start.hour}:${event.start.minute} - ${event.end?.hour}:${event.end?.minute}",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        
      ],
    );
  }
}

class TimeGapSelection extends StatelessWidget {
  const TimeGapSelection({
    super.key,
    required this.timeGap,
    required this.onChanged,
  });

  final int timeGap;
  final void Function(int?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('TimeGap:'),
        Radio<int>(
          value: 15,
          groupValue: timeGap,
          onChanged: onChanged,
        ),
        const Text('15m'),
        Radio<int>(
          value: 20,
          groupValue: timeGap,
          onChanged: onChanged,
        ),
        const Text('20m'),
        Radio<int>(
          value: 30,
          groupValue: timeGap,
          onChanged: onChanged,
        ),
        const Text('30m'),
        Radio<int>(
          value: 60,
          groupValue: timeGap,
          onChanged: onChanged,
        ),
        const Text('60m'),
      ],
    );
  }
}
