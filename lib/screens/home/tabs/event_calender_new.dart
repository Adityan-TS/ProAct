import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:proact/core/value/app_colors.dart';
import '../../../controller/home_controller.dart';
import '../../../tabs/overflow_day_view_tab.dart';

class EventCalenderNew extends HookWidget {
  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0,left: 15,bottom: 25),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Planner",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                      Text("Plan time on your calendar to scieve your results",style: TextStyle(fontSize: 13,color: Colors.white),),
                    ],
                  ),
                ),
              ),
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.shade900,
                      Colors.black,
                      Colors.black,
                    ]
                )
              ),

            ),
            Padding(
              padding:  EdgeInsets.only(top: 100),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Theme.of(context).scaffoldBackgroundColor
                ),
                height: MediaQuery.of(context).size.height * 0.80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DateSelector(context),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                        child: OverflowDayViewTab(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget DateSelector(BuildContext con ) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(200),
      child: EasyDateTimeLine(
        initialDate: controller.selectedDate.value,
        onDateChange: (selectedDate) {
          controller.selectedDate.value = selectedDate; // Update reactive date
        },
        dayProps: EasyDayProps(
          todayNumStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          activeDayStyle: DayStyle(
            dayNumStyle: TextStyle(color: Theme.of(con).scaffoldBackgroundColor),
          ),
          inactiveDayStyle: const DayStyle(dayNumStyle: TextStyle()),
          borderColor: Theme.of(con).iconTheme.color ?? Colors.black,
          todayHighlightStyle: TodayHighlightStyle.withBorder,
        ),
        headerProps: EasyHeaderProps(
          monthPickerType: MonthPickerType.dropDown,
          monthStyle: TextStyle(color: AppColors.kblack),
          selectedDateStyle: TextStyle(),
        ),
        activeColor: Theme.of(con).iconTheme.color,
      ),
    );
  }

}
