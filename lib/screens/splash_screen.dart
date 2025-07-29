import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/constants/image_path.dart';
import 'package:proact/controller/home_controller.dart';
import 'package:proact/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routes/routes.dart';
import '../utils/hive_store_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  HomeController homeController = Get.put(HomeController());
  void initState() {
    Future.delayed(const Duration(seconds: 2),() async{
      final user = Supabase.instance.client.auth.currentUser;
      if(user == null){
        Get.offNamed(Routes.loginScreen);
      } else {
        await homeController.loadUserTasks();
        Get.offNamed(Routes.homeScreen);
        if (homeController.weeklyTasks.isNotEmpty) {
          await showYesterdayUncompletedTasksDialog(context);
        }
        Get.offNamed(Routes.homeScreen); // Happens after dialog

      }
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(ImagePath.appLogo,
              height: 150,
              width: 150,
            ),
            const SizedBox(
              height: 150,
            ),
            Text(
              "AppLock".toUpperCase(),
              style: GoogleFonts.ubuntu(
                textStyle: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 5,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
