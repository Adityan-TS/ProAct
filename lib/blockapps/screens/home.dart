import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';
import 'package:proact/blockapps/executables/controllers/permission_controller.dart';
import 'package:proact/blockapps/executables/controllers/apps_controller.dart';
import 'package:proact/blockapps/screens/unlocked_apps.dart';
import 'package:proact/blockapps/widgets/ask_permission_dialog.dart';

// #region debug-point A:dbg-reporter
const String _dbgUrl =
    String.fromEnvironment('DEBUG_SERVER_URL', defaultValue: 'http://127.0.0.1:7777/event');
const String _dbgSessionId =
    String.fromEnvironment('DEBUG_SESSION_ID', defaultValue: 'block-apps-tab-crash');
void _dbg(String hypothesisId, String location, String msg,
    [Map<String, Object?> data = const {}]) {
  () async {
    try {
      final payload = jsonEncode({
        'sessionId': _dbgSessionId,
        'runId': 'pre',
        'hypothesisId': hypothesisId,
        'location': location,
        'msg': msg,
        'data': data,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      final client = HttpClient();
      final req = await client.postUrl(Uri.parse(_dbgUrl));
      req.headers.contentType = ContentType.json;
      req.write(payload);
      await req.close();
      client.close();
    } catch (_) {}
  }();
}
// #endregion

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
      // #region debug-point A:blocked-home-open
      _dbg('A', 'home.dart:initState', '[DEBUG] Block Apps open: initState', {
        'platform': Platform.operatingSystem,
        'ts': DateTime.now().toIso8601String(),
      });
      // #endregion
      try {
        // #region debug-point A:getAppsData:start
        _dbg('A', 'home.dart:initState', '[DEBUG] getAppsData:start');
        // #endregion
        await Get.find<AppsController>().getAppsData();
        // #region debug-point A:getAppsData:ok
        _dbg('A', 'home.dart:initState', '[DEBUG] getAppsData:ok', {
          'count': Get.find<AppsController>().unLockList.length,
        });
        // #endregion
      } catch (e, st) {
        // #region debug-point A:getAppsData:error
        _dbg('A', 'home.dart:initState', '[DEBUG] getAppsData:error', {
          'error': e.toString(),
          'stack': st.toString(),
        });
        // #endregion
        rethrow;
      }

      try {
        // #region debug-point C:getLockedApps:start
        _dbg('C', 'home.dart:initState', '[DEBUG] getLockedApps:start');
        // #endregion
        Get.find<AppsController>().getLockedApps();
        // #region debug-point C:getLockedApps:ok
        _dbg('C', 'home.dart:initState', '[DEBUG] getLockedApps:ok', {
          'lockedCount': Get.find<AppsController>().lockList.length,
        });
        // #endregion
      } catch (e, st) {
        // #region debug-point C:getLockedApps:error
        _dbg('C', 'home.dart:initState', '[DEBUG] getLockedApps:error', {
          'error': e.toString(),
          'stack': st.toString(),
        });
        // #endregion
        rethrow;
      }

      try {
        // #region debug-point B:ignoreBatteryOpt:start
        _dbg('B', 'home.dart:initState', '[DEBUG] ignoreBatteryOptimizations:start');
        // #endregion
        await Get.find<PermissionController>()
            .getPermission(Permission.ignoreBatteryOptimizations);
        // #region debug-point B:ignoreBatteryOpt:ok
        _dbg('B', 'home.dart:initState', '[DEBUG] ignoreBatteryOptimizations:ok');
        // #endregion
      } catch (e, st) {
        // #region debug-point B:ignoreBatteryOpt:error
        _dbg('B', 'home.dart:initState', '[DEBUG] ignoreBatteryOptimizations:error', {
          'error': e.toString(),
          'stack': st.toString(),
        });
        // #endregion
        rethrow;
      }

      try {
        // #region debug-point B:getPermissions:start
        _dbg('B', 'home.dart:initState', '[DEBUG] getPermissions:start');
        // #endregion
        await getPermissions();
        // #region debug-point B:getPermissions:ok
        _dbg('B', 'home.dart:initState', '[DEBUG] getPermissions:ok', {
          'overlay': Get.find<MethodChannelController>().isOverlayPermissionGiven,
          'usage': Get.find<MethodChannelController>().isUsageStatPermissionGiven,
          'notification': Get.find<MethodChannelController>().isNotificationPermissionGiven,
        });
        // #endregion
      } catch (e, st) {
        // #region debug-point B:getPermissions:error
        _dbg('B', 'home.dart:initState', '[DEBUG] getPermissions:error', {
          'error': e.toString(),
          'stack': st.toString(),
        });
        // #endregion
        rethrow;
      }

      try {
        // #region debug-point E:addToLockedAppsMethod:start
        _dbg('E', 'home.dart:initState', '[DEBUG] addToLockedAppsMethod:start', {
          'lockedCount': Get.find<AppsController>().lockList.length,
        });
        // #endregion
        await Get.find<MethodChannelController>().addToLockedAppsMethod();
        // #region debug-point E:addToLockedAppsMethod:ok
        _dbg('E', 'home.dart:initState', '[DEBUG] addToLockedAppsMethod:ok');
        // #endregion
      } catch (e, st) {
        // #region debug-point E:addToLockedAppsMethod:error
        _dbg('E', 'home.dart:initState', '[DEBUG] addToLockedAppsMethod:error', {
          'error': e.toString(),
          'stack': st.toString(),
        });
        // #endregion
        rethrow;
      }

      try {
        // #region debug-point E:startRobustAppBlock:start
        _dbg('E', 'home.dart:initState', '[DEBUG] startRobustAppBlock:start');
        // #endregion
        await Get.find<MethodChannelController>().startRobustAppBlock();
        // #region debug-point E:startRobustAppBlock:ok
        _dbg('E', 'home.dart:initState', '[DEBUG] startRobustAppBlock:ok');
        // #endregion
      } catch (e, st) {
        // #region debug-point E:startRobustAppBlock:error
        _dbg('E', 'home.dart:initState', '[DEBUG] startRobustAppBlock:error', {
          'error': e.toString(),
          'stack': st.toString(),
        });
        // #endregion
        rethrow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const UnlockedAppScreen();
  }
}
