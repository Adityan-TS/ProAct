
import 'package:get/get.dart';
import 'package:proact/services/user_service.dart';
import 'package:proact/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class TasksService {

  static var client = Supabase.instance.client;
  static var tasks = "Tasks";
  static var id = "id";
  static var createdBy = "created_by";
  static var title = "title";
  static var description = "description";
  static var startTime = "start_time";
  static var endTime = "end_time";
  static var status = "status";
  static var createdAt = "created_at";

  static insertTask(task)async{
    final insertResponse = await client
        .from(tasks)
        .insert(task);
    return insertResponse;
  }

  static Future<List<Map<String, dynamic>>> updateTaskStatus(int taskId, int newStatus) async {

    try {
      final response = await client
          .from(tasks)
          .update({status: newStatus})
          .eq(id, taskId)
          .select();

      print('✅ Task status updated: $response');
      return response;
    } catch (e) {
      print('❗ Error updating task status: $e');
      throw Exception('Error updating task status: $e');
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> getCategorizedTasks() async {
    try {
      final user = await UserService.getCurrentUserData();
      final userId = user.userId;

      final data = await client
          .from(tasks)
          .select()
          .eq(createdBy, userId)
          .order(startTime, ascending: true); // Sorted by start_time

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      List<Map<String, dynamic>> todayTasks = [];
      List<Map<String, dynamic>> yesterdayTasks = [];
      List<Map<String, dynamic>> weeklyTasks = [];
      List<Map<String, dynamic>> monthlyTasks = [];

      for (var task in data) {
        final createdAt = DateTime.parse(task['created_at']);
        final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

        if (createdDate == today) {
          todayTasks.add(task);
        }

        if (createdDate == yesterday) {
          yesterdayTasks.add(task);
        }

        if (createdDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            createdDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          weeklyTasks.add(task);
        }

        if (createdDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            createdDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          monthlyTasks.add(task);
        }
      }

      return {
        'today': todayTasks,
        'yesterday': yesterdayTasks,
        'week': weeklyTasks,
        'month': monthlyTasks,
      };
    } catch (e) {
      print('❗ Error getting categorized tasks: $e');
      throw Exception('Error getting categorized tasks: $e');
    }
  }

  static Future<void> importTask(selectedIndexes,uncompletedTasks) async {
    final today = DateTime.now();
    for (var index in selectedIndexes) {
      final task = uncompletedTasks[index];
      await client.from(tasks).update({
        createdAt : today.toIso8601String(),
      }).eq(id, task.id);
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getTaskCounts() async {
    try {
      final user = await UserService.getCurrentUserData();
      final userId = user.userId;

      final response = await client
          .from(tasks)
          .select('id, status, created_at, start_time')
          .eq(createdBy, userId)
          .order('start_time', ascending: true);

      final List<Map<String, dynamic>> allTasks = List<Map<String, dynamic>>.from(response);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      int todayTotal = 0, todayCompleted = 0;
      int weekTotal = 0, weekCompleted = 0;
      int monthTotal = 0, monthCompleted = 0;

      for (var task in allTasks) {
        final createdAt = DateTime.parse(task['created_at']);
        final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final isCompleted = task['status'] == 1;

        if (createdDate == today) {
          todayTotal++;
          if (isCompleted) todayCompleted++;
        }

        if (createdDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
            createdDate.isBefore(endOfWeek.add(Duration(days: 1)))) {
          weekTotal++;
          if (isCompleted) weekCompleted++;
        }

        if (createdDate.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
            createdDate.isBefore(endOfMonth.add(Duration(days: 1)))) {
          monthTotal++;
          if (isCompleted) monthCompleted++;
        }
      }

      return {
        'today': {
          'total': todayTotal,
          'completed': todayCompleted,
        },
        'week': {
          'total': weekTotal,
          'completed': weekCompleted,
        },
        'month': {
          'total': monthTotal,
          'completed': monthCompleted,
        },
      };
    } catch (e) {
      print('❗ Error getting task counts: $e');
      throw Exception('Error getting task counts: $e');
    }
  }

  static updateTask(taskId,task)async{
    final insertResponse = await client
        .from(tasks)
        .update(task)
    .eq(id, taskId);
    return insertResponse;
  }

  static Future deleteTask(taskId) async {
    try {
      final data = await client
          .from(tasks)
          .delete()
          .eq(id, taskId);
      return data;
    } catch (e) {
      print('❗ Error getting tasks: $e');
      throw Exception('Error getting tasks: $e');
    }
  }
}