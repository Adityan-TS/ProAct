import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proact/blockapps/services/init.dart';
import 'package:proact/controller/home_controller.dart';
import 'package:proact/controller/theme_controller.dart';
import 'package:proact/services/task_service.dart';
import 'package:proact/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/constants.dart';
import 'core/value/theme_data.dart';
import 'custom_elements/custom_elements.dart';
import 'notification_service.dart';
import 'routes/routes.dart';
import 'routes/screens.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseUrl,
    anonKey: SupabaseKey,
  );

  // Initialize Gemini
  // Gemini.init(
  //   apiKey: 'AIzaSyDHtx8QtdqWHUpNEd8J_nogM3tjjj5NSEA',
  // );
  await Hive.initFlutter();
  await Hive.openBox('ProAct');
  notifyService.initialiseNotifications();

  runApp(ProAct());
}

class ProAct extends StatefulWidget {

  @override
  State<ProAct> createState() => _ProActState();
}

class _ProActState extends State<ProAct> {
  ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        title: 'ProAct+',
        builder: EasyLoading.init(
          builder: (context, child) => MediaQuery(
            child: child!,
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
          ),
        ),
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        getPages: Screens.routes,
        initialRoute: Routes.splashScreen,
        debugShowCheckedModeBanner: false,
      );
    });
  }

}