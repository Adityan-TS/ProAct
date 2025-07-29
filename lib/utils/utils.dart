import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:proact/constants/constants.dart';
import 'package:proact/controller/home_controller.dart';
import 'package:proact/model/task_model.dart';

import '../controller/dashbord_controller.dart';
import '../custom_elements/elements/custom_colors.dart';
import '../services/task_service.dart';

///  this class contains small functions like validation and checking
///  functions that we can use in all pages.

class Utils {
 static showToast(String value) {
  Fluttertoast.showToast(
   msg: value,
   toastLength: Toast.LENGTH_LONG,
   gravity: ToastGravity.CENTER,
   timeInSecForIosWeb: 1,
   textColor: Colors.white,
   backgroundColor: Colors.black,
   fontSize: 16.0,
  );
 }

 static bool isValidEmail(String? value) => RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value ?? '');
 // static bool isValidPhoneNumber(String? value) => RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{3}$)').hasMatch(value ?? '');
 static bool isValidPhoneNumber(String? value) => (value!.length == 9);

 static Future<bool> isInternetConnected()async{
  try {
   final result = await InternetAddress.lookup('https://www.google.com');
   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    return true;
   }
  } on SocketException catch (_) {
   printLog('not internet connected');
  }
  return false;
 }

 static showLoading({String msg = 'Loading...'}){
  EasyLoading.show(status: msg,indicator: CircularProgressIndicator(color: CustomColors.primary,),dismissOnTap: false,maskType: EasyLoadingMaskType.black);
 }

 static closeLoading() {
  EasyLoading.dismiss();
 }

 static openDatePicker(BuildContext context,Function(DateTime?) onDone,{DateTime? initDate}){
  showDatePicker(
   context: context,
   initialDate: initDate ?? DateTime.now(),
   firstDate: DateTime(1900),
   lastDate: DateTime(5000),
   builder: (context, child) {
    return child!;
   },
  ).then((value) => onDone(value));
 }
}

DateTime? currentBackPressTime;

Future<bool> onWillPop(BuildContext context) {
 DateTime now = DateTime.now();
 if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
  currentBackPressTime = now;

  Utils.showToast("Tap again to exit from app.",);
  return Future.value(false);
 }
 return Future.value(true);
}

Future<bool> backPressed(BuildContext context) async {
 bool back = await onWillPop(context );
 if (back) {
  if (Platform.isAndroid)
   SystemNavigator.pop();
  else
   exit(0);
 }
 return back;
}
Future<void> showYesterdayUncompletedTasksDialog(BuildContext context) {
 HomeController homeController = Get.find();
 final uncompletedTasks =
 homeController.weeklyTasks.where((task) => task.status == 0).toList();
 Set<int> selectedIndexes = {};

 return showDialog(
  context: context,
  builder: (context) => StatefulBuilder(
   builder: (context, setState) {
    return AlertDialog(
     title: const Text(
      "Import Incomplete Tasks from Previous day",
      style: TextStyle(fontSize: 14),
     ),
     content: SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
       shrinkWrap: true,
       itemCount: uncompletedTasks.length,
       itemBuilder: (context, index) {
        final task = uncompletedTasks[index];
        return Container(
         margin: const EdgeInsets.symmetric(vertical: 6),
         decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Get.theme.scaffoldBackgroundColor,
          boxShadow: const [
           BoxShadow(color: Colors.grey, blurRadius: 2)
          ],
         ),
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
           children: [
            Expanded(
             child: Text(
              task.title,
              style: const TextStyle(fontSize: 13),
             ),
            ),
            Checkbox(
             value: selectedIndexes.contains(index),
             checkColor: Get.theme.iconTheme.color,
             fillColor:
             const WidgetStatePropertyAll(Colors.transparent),
             onChanged: (value) {
              setState(() {
               if (value == true) {
                selectedIndexes.add(index);
               } else {
                selectedIndexes.remove(index);
               }
              });
             },
            ),
           ],
          ),
         ),
        );
       },
      ),
     ),
     actions: [
      TextButton(
       onPressed: () => Get.back(),
       child: Text(
        "Close",
        style: TextStyle(color: Theme.of(context).iconTheme.color),
       ),
      ),
      if (uncompletedTasks.isNotEmpty)
       ElevatedButton(
        onPressed: () async {
         Utils.showLoading();
         await TasksService.importTask(selectedIndexes, uncompletedTasks);
         Get.find<DashboardController>().updateProgress();

         await Future.delayed(const Duration(milliseconds: 200));
         await Get.find<HomeController>().loadUserTasks();

         Get.back(); // Close dialog
         Utils.closeLoading();
        },
        style: ElevatedButton.styleFrom(
         padding:
         const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
         backgroundColor: Theme.of(context).iconTheme.color,
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
         ),
         elevation: 3,
        ),
        child: Text(
         "Import",
         style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).scaffoldBackgroundColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
         ),
        ),
       ),
     ],
    );
   },
  ),
 );
}
