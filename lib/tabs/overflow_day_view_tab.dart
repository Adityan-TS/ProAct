import 'dart:collection';

import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

final now = DateTime.now();

class OverflowDayViewTab extends HookWidget {
  const OverflowDayViewTab({
    Key? key,
    this.onTimeTap,
  }) : super(key: key);

  final Function(DateTime)? onTimeTap;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    final timeGap = useState<int>(60);
    final renderAsList = useState<bool>(true);
    final cropBottomEvents = useState<bool>(true);
    final size = MediaQuery.sizeOf(context);

    return Column(
      children: [
        Expanded(
          child:Obx(() {
            DateTime selected = controller.selectedDate.value;
            return CalendarDayView.overflow(
              currentDate: selected,
              events: UnmodifiableListView(
                controller.parsedDayEvents.where((event) =>
                event.start.year == selected.year &&
                    event.start.month == selected.month &&
                    event.start.day == selected.day
                ).toList(),
              ),
              onTimeTap: onTimeTap ?? print,
              timeTextStyle: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 11),
              dividerColor: Theme.of(context).iconTheme.color,
              timeGap: timeGap.value,
              heightPerMin: 1.2,
              startOfDay: const TimeOfDay(hour: 0, minute: 0),
              endOfDay: const TimeOfDay(hour: 24, minute: 0),
              renderRowAsListView: renderAsList.value,
              showCurrentTimeLine: true,
              cropBottomEvents: cropBottomEvents.value,
              showMoreOnRowButton: true,
              currentTimeLineColor: Colors.blue,
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
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      width: !renderAsList.value
                          ? (constraints.minWidth - 6)
                          : size.width / 3 - 4,
                      height: constraints.maxHeight - 6,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 26, 26, 26),
                        border: Border.all(color: Colors.white24, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "${event.value}\n${event.start.hour}:${event.start.minute.toString().padLeft(2, '0')} - ${event.end?.hour}:${event.end?.minute.toString().padLeft(2, '0')}",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            );
          })
          ,
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
