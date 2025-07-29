import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/screens/home/tabs/widgets/task_chart.dart';

import '../../../../controller/dashbord_controller.dart';
import '../../../../controller/home_controller.dart';
import '../../../../core/value/app_colors.dart';

class ChartTabBar extends StatelessWidget {
  ChartTabBar({super.key});
  DashboardController dashboardController = Get.find();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).iconTheme.color == AppColors.kblack
                    ? Colors.grey.withOpacity(0.4)
                    : Colors.black.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
            color: Theme.of(context).iconTheme.color == AppColors.kblack
                ? Colors.white
                : Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: GetBuilder<HomeController>(
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.zero,
                    dividerHeight: 0,
                    indicatorColor: Get.theme.iconTheme.color,
                    unselectedLabelColor: Colors.grey,
                    labelColor: Get.theme.iconTheme.color ,
                    tabs: const [
                      Tab(text: "Today"),
                      Tab(text: "Week"),
                      Tab(text: "Month"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      height: 200, // Adjust as needed
                      child: Obx(() => TabBarView(
                        children: [
                          TaskChartRow(
                            totalTask: dashboardController.todayTotalTask.value,
                            completedTask:
                            dashboardController.todayCompletedTask.value,
                          ),
                          TaskChartRow(
                            totalTask: dashboardController.weekTotalTask.value,
                            completedTask:
                            dashboardController.weekCompletedTask.value,
                          ),
                          TaskChartRow(
                            totalTask: dashboardController.monthTotalTask.value,
                            completedTask:
                            dashboardController.monthCompletedTask.value,
                          ),
                        ],
                      ),),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

  }
}