import 'package:get/get.dart';

import '../services/task_service.dart';

class DashboardController extends GetxController {
  Rx<int> todayTotalTask = 0.obs;
  Rx<int> todayCompletedTask = 0.obs;
  Rx<int> weekTotalTask = 0.obs;
  Rx<int> weekCompletedTask = 0.obs;
  Rx<int> monthTotalTask = 0.obs;
  Rx<int> monthCompletedTask = 0.obs;

  void updateProgress() async {
    try {
      final data = await TasksService.getTaskCounts();

      todayTotalTask.value = data['today']!['total'];
      todayCompletedTask.value = data['today']!['completed'];

      weekTotalTask.value = data['week']!['total'];
      weekCompletedTask.value = data['week']!['completed'];

      monthTotalTask.value = data['month']!['total'];
      monthCompletedTask.value = data['month']!['completed'];
    } catch (e) {
      print('❗ Error updating task progress: $e');
    }
  }


  @override
  void onInit() {
    updateProgress();
    super.onInit();
  }
}
