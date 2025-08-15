import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';
import 'package:proact/blockapps/executables/controllers/permission_controller.dart';
import 'package:proact/blockapps/executables/controllers/apps_controller.dart';
import 'package:proact/blockapps/screens/unlocked_apps.dart';
import 'package:proact/blockapps/widgets/ask_permission_dialog.dart';

class BlockedHomePage extends StatefulWidget {
  const BlockedHomePage({Key? key}) : super(key: key);

  @override
  State<BlockedHomePage> createState() => _BlockedHomePageState();
}

class _BlockedHomePageState extends State<BlockedHomePage> {
  getPermissions() async {
    if (!(await Get.find<MethodChannelController>()
            .checkNotificationPermission()) ||
        !(await Get.find<MethodChannelController>().checkOverlayPermission()) ||
        !(await Get.find<MethodChannelController>()
            .checkUsageStatePermission())) {
      Get.find<MethodChannelController>().update();
      askPermissionBottomSheet(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Get.find<AppsController>().getAppsData();
      Get.find<AppsController>().getLockedApps();
      Get.find<PermissionController>()
          .getPermission(Permission.ignoreBatteryOptimizations);
      getPermissions();
      Get.find<MethodChannelController>().addToLockedAppsMethod();
      Get.find<MethodChannelController>().startRobustAppBlock();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const UnlockedAppScreen();
  }
}
