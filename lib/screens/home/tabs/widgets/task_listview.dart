import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/controller/home_controller.dart';
import 'package:proact/custom_elements/custom_elements.dart';
import 'package:proact/model/task_model.dart';

import '../../../../controller/dashbord_controller.dart';
import '../../../../notification_service.dart';
import '../../../../services/task_service.dart';
import 'event_card.dart';

class TaskListview extends StatelessWidget {
  TaskListview({super.key});
  HomeController homeController = Get.put(HomeController());
  DashboardController controller = Get.put(DashboardController());
  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            'Today',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() {
          return Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: homeController.isLoading.value
                ? const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                child: CircularProgressIndicator(color: Colors.grey),
              ),
            )
                : homeController.tasksList.isEmpty
                ?  Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                child: Text(
                  "No Task",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
                : GetBuilder<HomeController>(builder: (ctrl) {

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeController.todayTasks.length,
                itemBuilder: (context, index) {
                  TaskModel task =  homeController.todayTasks[index];
                  return EventCard(
                     index: index,
                    listLength: homeController.todayTasks.length,
                    task: task,
                    showGeminiPrompt: () {
                      homeController.showGeminiPrompt(context, index);
                    },
                    onDelete: () async {
                      notifyService.cancelEventNotification(index);
                      await homeController.deleteTask(task.id,);
                      homeController.todayTasks.removeAt(index);
                      homeController.update();
                      DashboardController contriller = Get.find();
                      contriller.updateProgress();
                    },
                    markAsDone: () async {
                      homeController.todayTasks[index].status = task.status == 0 ? 1 : 0;
                      await homeController.updateTaskStatus(task.id, task.status);
                      homeController.update();
                      DashboardController contriller = Get.find();
                      contriller.updateProgress();
                    },
                    onEdit: () {
                      showEditTaskDialog(
                        context: context,
                        task: task,
                        index: index,
                        onSave: (updatedTask) async {
                          homeController.todayTasks[index].title = updatedTask[TasksService.title];
                          homeController.todayTasks[index].endTime = updatedTask[TasksService.endTime];
                          homeController.todayTasks[index].startTime = updatedTask[TasksService.startTime];
                          await homeController.updateTask(task.id, updatedTask);
                          homeController.update();
                        },
                      );
                    },
                  );
                },
              );
            }),
          );
        })
      ],
    );
  }

  void showEditTaskDialog({
    required BuildContext context,
    required TaskModel task,
    required int index,
    required Function(Map<String, dynamic>) onSave,
  }) {
    final taskNameController = TextEditingController(text: task.title ?? '');
    final txtStartTimeController = TextEditingController(text: task.startTime ?? '');
    final txtEndTimeController = TextEditingController(text: task.endTime ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF1A1A1A),
        ),
        buttonPadding: const EdgeInsets.all(25),
        actions: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 15, color: Colors.grey)),
          ),
          InkWell(
            onTap: () {
              onSave({
                TasksService.title: taskNameController.text,
                TasksService.startTime: txtStartTimeController.text,
                TasksService.endTime: txtEndTimeController.text
              });
              Navigator.pop(context);
            },
            child: const Text("Save Task", style: TextStyle(fontSize: 15, color: Colors.blue)),
          ),
        ],
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLabel("Task Name"),
              TextField(
                controller: taskNameController,
                decoration: const InputDecoration(hintText: "Task Name"),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildLabel("Start Time"),
              TextField(
                controller: txtStartTimeController,
                readOnly: true,
                onTap: () async {
                  final time = await _pickTime(context, task.startTime);
                  if (time != null) txtStartTimeController.text = time;
                },
                decoration: const InputDecoration(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildLabel("End Time"),
              TextField(
                controller: txtEndTimeController,
                readOnly: true,
                onTap: () async {
                  final time = await _pickTime(context, task.endTime);
                  if (time != null) txtEndTimeController.text = time;
                },
                decoration: const InputDecoration(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Future<String?> _pickTime(BuildContext context, String? initial) async {
    if (initial == null || !initial.contains(":")) return null;
    final parts = initial.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final min = int.tryParse(parts[1]) ?? 0;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: min),
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (time != null) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return "$h:$m";
    }
    return null;
  }

}
