import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/blockapps/screens/home.dart';
import 'package:proact/routes/routes.dart';
import 'package:proact/screens/home/tabs/widgets/chart_tab_bar.dart';
import 'package:proact/screens/home/tabs/widgets/task_chart.dart';
import 'package:proact/screens/home/tabs/widgets/task_listview.dart';
import 'package:proact/services/task_service.dart';
import 'package:proact/services/user_service.dart';
import 'package:proact/utils/app_urls.dart';
import 'package:proact/utils/hive_store_util.dart';
import '../../../controller/home_controller.dart';
import '../../../controller/dashbord_controller.dart';
import '../../../model/user_model.dart';
import '../../../utils/utils.dart';

// #region debug-point D:dbg-reporter
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

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: null,
        backgroundColor: Colors.transparent,
        title: GetBuilder<DashboardController>(builder: (controller) {
          UserModel user = UserService.getCurrentUserData();

          return Row(
            children: [
              InkWell(
                onTap: () => Get.toNamed(Routes.profileScreen),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.photo.isNotEmpty
                        ? user.photo
                        :"https://www.manageengine.com/images/speaker-placeholder.png"
                    ),
                  ),
                ),
              ),
               Text(
                  'Hi, ${HiveStoreUtil.getString(HiveStoreUtil.firstNameKey)}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          );
        },),
        actions: [
           Padding(
              padding: EdgeInsets.all(0),
              child: IconButton(
                onPressed: () {
                  // #region debug-point D:blockapps-button
                  _dbg('D', 'dashboard_screen.dart:IconButton', '[DEBUG] Block Apps button pressed');
                  // #endregion
                 showBlockAppDialog(context);
                },
                icon: Icon(Icons.lock,size: 25,color: Theme.of(context).iconTheme.color,),
              ),
           ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh:() =>  homeController.loadUserTasks(),
        child: ListView(
          children: [
            ChartTabBar(),
            TaskListview()
          ],
        ),
      ),
    );
  }

  Future showBlockAppDialog(BuildContext context) {
     // #region debug-point D:blockapps-dialog
     _dbg('D', 'dashboard_screen.dart:showBlockAppDialog', '[DEBUG] showBlockAppDialog called');
     // #endregion
     return showDialog(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          margin: EdgeInsets.fromLTRB(25, 30, 25, 30),
          child: BlockedHomePage(),
        );
      },
    );
  }

}
