import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/screens/auth/intro_screen.dart';
import 'package:proact/screens/auth/login_screen.dart';
import 'package:proact/screens/auth/reset_password.dart';
import 'package:proact/screens/auth/signup_screen.dart';
import 'package:proact/screens/home/home_screen.dart';
import 'package:proact/screens/profile/chnage_password/change_password_screen.dart';
import 'package:proact/screens/splash_screen.dart';

import '../screens/profile/edit_profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'routes.dart';

class Screens{

  static final routes = [
    GetPage(name: Routes.splashScreen, page: () => SplashScreen(),),
    GetPage(name: Routes.introScreen, page: () => IntroScreen(),),
    GetPage(name: Routes.loginScreen, page: () => LoginScreen(),),
    GetPage(name: Routes.signupScreen, page: () => SignUpScreen(),),
    GetPage(name: Routes.resetPasswordScreen, page: () => ResetPassword(),),
    GetPage(name: Routes.homeScreen, page: () => HomeScreen(),),
    GetPage(name: Routes.profileScreen, page: () => ProfileScreen(),),
    GetPage(name: Routes.editProfileScreen, page: () => EditProfileScreen(),),
    GetPage(name: Routes.changePasswordScreen, page: () => ChangePasswordScreen(),),
  ];

}
