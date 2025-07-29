import 'package:get/get.dart';
import 'package:proact/blockapps/executables/controllers/apps_controller.dart';
import '../executables/controllers/method_channel_controller.dart';
import '../executables/controllers/password_controller.dart';
import '../executables/controllers/permission_controller.dart';

Future<void> initialize() async {
  Get.lazyPut(() => AppsController());
  Get.lazyPut(() => MethodChannelController());
  Get.lazyPut(() => PermissionController());
  Get.lazyPut(() => PasswordController());
}
