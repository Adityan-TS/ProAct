import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:new_device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';
import 'package:proact/blockapps/services/constant.dart';
import '../../../utils/hive_store_util.dart';
import '../../../model/application_model.dart';

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

class AppsController extends GetxController implements GetxService {
  String? dummyPasscode;
  int? selectQuestion;
  TextEditingController typeAnswer = TextEditingController();
  TextEditingController checkAnswer = TextEditingController();
  TextEditingController searchApkText = TextEditingController();
  List<Application> unLockList = [];
  List<ApplicationDataModel> searchedApps = [];
  List<ApplicationDataModel> lockList = [];
  List<String> selectLockList = [];
  bool addToAppsLoading = false;

  List<String> excludedApps = ["com.android.settings"];

  int appSearchUpdate = 1;
  int addRemoveToUnlockUpdate = 2;
  int addRemoveToUnlockUpdateSearch = 3;

  changeQuestionIndex(index) {
    selectQuestion = index;
    update();
  }

  resetAskQuetionsPage() {
    selectQuestion = null;
    typeAnswer.clear();
    checkAnswer.clear();
  }

  savePasscode(counter) {
    HiveStoreUtil.setString(HiveStoreUtil.passCode,counter);
    Get.find<MethodChannelController>().setPassword();
  }

  getPasscode() {
    return HiveStoreUtil.getString(HiveStoreUtil.passCode);
  }

  removePasscode() {
    return HiveStoreUtil.setString(HiveStoreUtil.passCode, '');
  }

  excludeApps() {
    for (var e in excludedApps) {
      unLockList.removeWhere((element) => element.packageName == e);
    }
  }

  getAppsData() async {
    // #region debug-point A:getAppsData:controller-start
    _dbg('A', 'apps_controller.dart:getAppsData', '[DEBUG] DeviceApps.getInstalledApplications:start');
    // #endregion
    try {
      unLockList = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true,
      );
      // #region debug-point A:getAppsData:controller-ok
      _dbg('A', 'apps_controller.dart:getAppsData', '[DEBUG] DeviceApps.getInstalledApplications:ok', {
        'count': unLockList.length,
      });
      // #endregion
      excludeApps();
      update();
    } catch (e, st) {
      // #region debug-point A:getAppsData:controller-error
      _dbg('A', 'apps_controller.dart:getAppsData', '[DEBUG] DeviceApps.getInstalledApplications:error', {
        'error': e.toString(),
        'stack': st.toString(),
      });
      // #endregion
      rethrow;
    }
  }

  addRemoveFromLockedAppsFromSearch(ApplicationData app) {
    addToAppsLoading = true;
    update();
    try {
      if (selectLockList.contains(app.appName)) {
        selectLockList.remove(app.appName);
        lockList.removeWhere(
            (element) => element.application!.appName == app.appName);
      } else {
        if (lockList.length < 16) {
          selectLockList.add(app.appName);
          lockList.add(
            ApplicationDataModel(
              isLocked: true,
              application: ApplicationData(
                apkFilePath: app.apkFilePath,
                appName: app.appName,
                category: app.category,
                dataDir: app.dataDir,
                enabled: app.enabled,
                icon: getAppIcon(app.appName),
                installTimeMillis: app.installTimeMillis,
                packageName: app.packageName,
                systemApp: app.systemApp,
                updateTimeMillis: app.updateTimeMillis,
                versionCode: app.versionCode,
                versionName: app.versionName,
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("-------$e", name: "addRemoveFromLockedAppsFromSearch");
    }
    addToAppsLoading = false;
    update();
  }

  addToLockedApps(Application app, context) async {
    addToAppsLoading = true;
    update([addRemoveToUnlockUpdate]);
    try {
      if (selectLockList.contains(app.appName)) {
        selectLockList.remove(app.appName);
        lockList.removeWhere((em) => em.application!.appName == app.appName);
        log("REMOVE: $selectLockList");
      } else {
        if (lockList.length < 16) {
          selectLockList.add(app.appName);
          lockList.add(
            ApplicationDataModel(
              isLocked: true,
              application: ApplicationData(
                apkFilePath: app.apkFilePath,
                appName: app.appName,
                category: "${app.category}",
                dataDir: "${app.dataDir}",
                enabled: app.enabled,
                icon: (app as ApplicationWithIcon).icon,
                installTimeMillis: "${app.installTimeMillis}",
                packageName: app.packageName,
                systemApp: app.systemApp,
                updateTimeMillis: '${app.updateTimeMillis}',
                versionCode: '${app.versionCode}',
                versionName: '${app.versionName}',
              ),
            ),
          );
          log("ADD: $selectLockList", name: "addToLockedApps");
          Get.find<MethodChannelController>().addToLockedAppsMethod();
        Get.find<MethodChannelController>().startRobustAppBlock();
        } else {
          Fluttertoast.showToast(
              msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("-------$e", name: "addToLockedApps");
    }
    HiveStoreUtil.setString(HiveStoreUtil.lockedApps,  applicationDataModelToJson(lockList));
    addToAppsLoading = false;
    update([addRemoveToUnlockUpdate]);
  }

  getLockedApps() {
    try {
      lockList = applicationDataModelFromJson(HiveStoreUtil.getString(HiveStoreUtil.lockedApps));
      selectLockList.clear();
      log('${lockList.length}', name: "STORED LIST");
      for (var e in lockList) {
        selectLockList.add(e.application!.appName);
      }
      log('${lockList.length}-$selectLockList', name: "Locked Apps");
    } catch (e) {
      log("-------$e", name: "getLockedApps");
    }

    update();
  }

  Uint8List getAppIcon(String appName) {
    return (unLockList[unLockList.indexWhere((element) {
      return appName == element.appName;
    })] as ApplicationWithIcon)
        .icon;
  }

  appSearch() {
    searchedApps.clear();
    if (searchApkText.text.length > 2) {
      for (var e in unLockList) {
        if (e.appName
            .toUpperCase()
            .contains(searchApkText.text.toUpperCase().trim())) {
          searchedApps.add(
            ApplicationDataModel(
              isLocked: null,
              application: ApplicationData(
                apkFilePath: e.apkFilePath,
                appName: e.appName,
                category: "${e.category}",
                dataDir: "${e.dataDir}",
                enabled: e.enabled,
                icon: (e as ApplicationWithIcon).icon,
                installTimeMillis: "${e.installTimeMillis}",
                packageName: e.packageName,
                systemApp: e.systemApp,
                updateTimeMillis: '${e.updateTimeMillis}',
                versionCode: '${e.versionCode}',
                versionName: '${e.versionName}',
              ),
            ),
          );
        }
      }
      update([appSearchUpdate]);
    }
  }
}
