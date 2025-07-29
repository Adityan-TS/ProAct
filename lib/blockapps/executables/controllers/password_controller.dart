import 'dart:developer';

import 'package:proact/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../utils/hive_store_util.dart';

class PasswordController extends GetxController implements GetxService {
  bool isConfirm = false;
  String passcode = "";
  String addedPassCode = "";

  setPasscode(int index) {
    if (index == 10 && passcode.length < 6) {
      passcode = "${passcode}0";
    } else if (index == 11 && passcode.isNotEmpty) {
      List local = passcode.split("");
      local.removeLast();
      passcode = "";
      for (var element in local) {
        passcode = "$passcode$element";
      }
      log(passcode);
    } else if (index < 11 && passcode.length < 6) {
      passcode = "$passcode${index + 1}";
    }
    log("$passcode $index");
    update();
  }

  savePasscode() {
    // if(addedPassCode.isNotEmpty && passcode.is)
    if (!isConfirm) {
      if (passcode.isNotEmpty) {
        isConfirm = true;
        addedPassCode = passcode;
        passcode = "";
        update();
      } else {
        Fluttertoast.showToast(msg: "Invalid Passcode");
      }
    } else {
      if (addedPassCode == passcode) {
        HiveStoreUtil.setString(HiveStoreUtil.passCode,passcode);
        navigatorKey.currentState!.pop();
      } else {
        Fluttertoast.showToast(msg: "passcode does not match");
      }
    }
  }

  clearData() {
    isConfirm = false;
    passcode = "";
    update();
  }
}
