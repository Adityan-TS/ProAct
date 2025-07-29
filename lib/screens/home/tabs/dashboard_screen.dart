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
