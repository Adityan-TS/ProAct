import 'dart:convert';
import 'package:calendar_day_view/calendar_day_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';

import 'package:proact/model/task_model.dart';
import 'package:proact/services/task_service.dart';
import 'package:proact/services/user_service.dart';

import '../screens/home/gemini_prompt.dart';
import '../utils/utils.dart';
import 'dashbord_controller.dart';

class HomeController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  RxString userEmail = ''.obs;
  RxString emailPrefix = ''.obs;
  RxInt currentIndex = 0.obs;
  Rx<bool> isLoading = false.obs;
  Map<String, List<TaskModel>> tasksList = {
    'today': [],
    'week': [],
    'month': [],
    'yesterday': [],
  };
  List<TaskModel> todayTasks = <TaskModel>[];
  List<TaskModel> weeklyTasks = <TaskModel>[];
  List<TaskModel> monthlyTasks = <TaskModel>[];
  List<TaskModel> yesterdayTasks = <TaskModel>[];


  Future<void> loadUserTasks() async {
    isLoading.value = true;
    try {
      Map<String, List<Map<String, dynamic>>> data = await TasksService.getCategorizedTasks();

      tasksList = {
        'today': data['today']!.map((e) => TaskModel.fromJson(e)).toList(),
        'week': data['week']!.map((e) => TaskModel.fromJson(e)).toList(),
        'month': data['month']!.map((e) => TaskModel.fromJson(e)).toList(),
        'yesterday': data['yesterday']!.map((e) => TaskModel.fromJson(e)).toList(),
      };

      todayTasks = tasksList['today']!;
      weeklyTasks = tasksList['week']!;
      monthlyTasks = tasksList['month']!;
      yesterdayTasks = tasksList['yesterday']!;

      print("✅ todayTasks: ${todayTasks.length} YesterdayTask : ${yesterdayTasks.length} weeklyTasks : ${weeklyTasks.length} monthlyTasks :${monthlyTasks.length}");
      update();
      MethodChannelController ctrl = Get.put(MethodChannelController());
      ctrl.saveEvents(jsonEncode(todayTasks.map((e) => e.toLocalJson(),).toList()));
    } catch (e) {
      print('❗ Error fetching tasks: $e');
      tasksList = {'today': [], 'week': [], 'month': []};
      todayTasks = [];
      weeklyTasks = [];
      monthlyTasks = [];
      yesterdayTasks = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(taskId, newStatus) async {
    await TasksService.updateTaskStatus(taskId, newStatus);
  }

  Future<void> deleteTask(taskId) async {
    await TasksService.deleteTask(taskId);
  }

  Future<void> updateTask(taskId,task) async {
    await TasksService.updateTask(taskId,task);
  }

  @override
  void onInit() {
    loadUserTasks();
    super.onInit();
  }

  void showGeminiPrompt(BuildContext context, int eventId) {
    showModalBottomSheet(

      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
        final height = keyboardOpen
            ? MediaQuery.of(context).size.height * 0.9
            : MediaQuery.of(context).size.height * 0.5;
        return  Container(
          height: height,
          child: GeminiPrompt(
            onSubmit: (data) async{
              var user = await UserService.getCurrentUserData();
              var data2 = data.map((e) {
                e['created_by'] = user.userId;
                return e;
              }).toList();
              await saveEventData(data2);
              DashboardController contriller = Get.find();
              contriller.updateProgress();
            },
            eventId: eventId,
          ),
        );
      },
    );
  }

  Future<void> saveEventData(eventData) async {
    try {
      await TasksService.insertTask(eventData);
      loadUserTasks();
    } catch (e) {
      print('❗ Exception saving to Supabase: $e');
    }
  }

  List<DayEvent<String>> get parsedDayEvents {
    List<DayEvent<String>> dayEvents = [];

    for (var event in monthlyTasks) {
      try {
        String startTime = event.startTime.trim();
        String endTime = event.endTime.trim();

        var startSplit = startTime.split(":");
        var endSplit = endTime.split(":");

        int startHour = int.parse(startSplit[0]);
        int startMinutes = int.parse(startSplit[1].substring(0, 2));

        int endHour = int.parse(endSplit[0]);
        int endMinutes = int.parse(endSplit[1].substring(0, 2));

        String title = event.title;
        DateTime taskDate = event.createdAt;

        dayEvents.add(DayEvent<String>(
          start: DateTime(taskDate.year, taskDate.month, taskDate.day, startHour, startMinutes),
          end: DateTime(taskDate.year, taskDate.month, taskDate.day, endHour, endMinutes),
          value: title,
          name: title,
        ));
      } catch (e) {
        print("Error parsing event: $e");
      }
    }


    return dayEvents;
  }
}
