import 'package:flutter/material.dart';
import 'package:proact/custom_elements/custom_elements.dart';
import 'app_colors.dart';


class AppTheme {
  static final lightTheme = ThemeData(
    // useMaterial3: false,
    //----------Typography----------//
    fontFamily: 'Inter',
    //----------Scaffold Background----------//
    scaffoldBackgroundColor: AppColors.kWhite,
    //----------Icon Theme----------//
    iconTheme: IconThemeData(color: AppColors.kblack, size: 20.sp),

    primaryColor: AppColors.kPrimaryColor,
    //---------AppBar's Theme---------//
    appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.kNeutral100Color),
        actionsIconTheme:
        IconThemeData(color: AppColors.kNeutral100Color, size: 24.sp)),

    //---------Floating Action Button's Theme---------//
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.kPrimaryColor,
        shape: CircleBorder(),
        splashColor: AppColors.kPrimaryFocusColor),

    //--------------Bottom Navigation Bar----------------//
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.kblack,
      unselectedItemColor: AppColors.kNeutral70Color,
      showUnselectedLabels: true,
      selectedLabelStyle: AppTextStyle.kCaption,
      unselectedLabelStyle: AppTextStyle.kCaption,
      backgroundColor: AppColors.kWhite
    ),

    //---------Text field theme---------//
    inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: AppTextStyle.kBodyMd
            .copyWith(color: AppColors.kNeutral80Color),
        floatingLabelStyle: AppTextStyle.kBodySm
            .copyWith(color: AppColors.kNeutral100Color),
        isDense: true,
        labelStyle: AppTextStyle.kBodyMd
            .copyWith(color: AppColors.kNeutral80Color, fontSize: 16.sp),

        //Enabled Border
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide:
            BorderSide(color: AppColors.kNeutral30Color, width: 1)),

        //Focus Border
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide:
            BorderSide(color: AppColors.kNeutral90Color, width: 1)),

        //Error Border
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(color: AppColors.kDanger1, width: 1)),

        //Error Focus Border
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(color: AppColors.kDanger1, width: 1)),

        //Suffix Icon Color
        suffixIconColor: AppColors.kNeutral80Color),

    //--------Checkbox theme---------//
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStatePropertyAll(AppColors.kWhite),
    ),

    textTheme: TextTheme(
      displayLarge: AppTextStyle.kHeading1,
      displayMedium: AppTextStyle.kHeading2,
      displaySmall: AppTextStyle.kHeading3,
      bodySmall: AppTextStyle.kBodySm,
      bodyMedium: AppTextStyle.kBodyMd,
      bodyLarge: AppTextStyle.kBodyLg,
      titleSmall: AppTextStyle.kCaption,
      headlineLarge: TextStyle(color: AppColors.kNeutral100Color,),
      labelLarge: TextStyle(color: AppColors.kNeutral100Color,),
      headlineMedium: TextStyle(color: AppColors.kNeutral100Color,),
      titleLarge: TextStyle(color: AppColors.kNeutral100Color,),
      headlineSmall: TextStyle(color: AppColors.kNeutral100Color,),
      labelMedium: TextStyle(color: AppColors.kNeutral100Color,),
      labelSmall: TextStyle(color: AppColors.kNeutral100Color,),
      titleMedium: TextStyle(color: AppColors.kNeutral100Color,),
    ),

    dialogTheme: DialogThemeData(backgroundColor: AppColors.kNeutral10Color,contentTextStyle: TextStyle(color: AppColors.kNeutral100Color,),),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.kPrimaryColor,
    //----------Typography----------//
    fontFamily: 'Inter',
    //----------Scaffold Background----------//
    scaffoldBackgroundColor: AppColors.kNeutral100Color,
    //----------Icon Theme----------//
    iconTheme: IconThemeData(color: AppColors.kNeutral10Color, size: 20.sp),

    //----------PopupMenu Theme----------//
    popupMenuTheme: PopupMenuThemeData(color: AppColors.kNeutral100Color,),

    //---------AppBar's Theme---------//
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.kWhite),
        actionsIconTheme:
        IconThemeData(color: AppColors.kNeutral90Color, size: 24.sp)),

    //---------Floating Action Button's Theme---------//
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.kPrimaryColor,
        splashColor: AppColors.kPrimaryFocusColor),

    //--------------Bottom Navigation Bar----------------//
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.kWhite,
      unselectedItemColor: AppColors.kNeutral70Color,
      showUnselectedLabels: true,
      selectedLabelStyle: AppTextStyle.kCaption,
      unselectedLabelStyle: AppTextStyle.kCaption,
      backgroundColor: AppColors.kNeutral100Color,
    ),

    //---------Text field theme---------//
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintStyle: AppTextStyle.kBodyMd
          .copyWith(color: AppColors.kNeutral80Color),
      floatingLabelStyle: AppTextStyle.kBodySm.copyWith(color: AppColors.kNeutral30Color),
      isDense: true,
      labelStyle: AppTextStyle.kBodyMd.copyWith(color: AppColors.kNeutral80Color, fontSize: 16.sp),

      //Enabled Border
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide:
          BorderSide(color: AppColors.kNeutral30Color, width: 1)),

      //Focus Border
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide:
          BorderSide(color: AppColors.kNeutral60Color, width: 1)),

      //Error Border
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: AppColors.kDanger1, width: 1)),

      //Error Focus Border
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: AppColors.kDanger1, width: 1)),

      //Suffix Icon Color
      suffixIconColor: AppColors.kNeutral80Color,

      fillColor: AppColors.kNeutral90Color,
    ),

    //--------Checkbox theme---------//
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(AppColors.kblack),
    ),

    textTheme: TextTheme(
      displayLarge: AppTextStyle.kHeading1.copyWith(color: AppColors.kNeutral10Color),
      displayMedium: AppTextStyle.kHeading2.copyWith(color: AppColors.kNeutral10Color),
      displaySmall: AppTextStyle.kHeading3.copyWith(color: AppColors.kNeutral10Color),
      bodySmall: AppTextStyle.kBodySm.copyWith(color: AppColors.kNeutral10Color),
      bodyMedium: AppTextStyle.kBodyMd.copyWith(color: AppColors.kNeutral10Color),
      bodyLarge: AppTextStyle.kBodyLg.copyWith(color: AppColors.kNeutral10Color),
      titleSmall: AppTextStyle.kCaption.copyWith(color: AppColors.kNeutral10Color),
      headlineLarge: TextStyle(color: AppColors.kNeutral10Color,),
      labelLarge: TextStyle(color: AppColors.kNeutral10Color,),
      headlineMedium: TextStyle(color: AppColors.kNeutral10Color,),
      titleLarge: TextStyle(color: AppColors.kNeutral10Color,),
      headlineSmall: TextStyle(color: AppColors.kNeutral10Color,),
      labelMedium: TextStyle(color: AppColors.kNeutral10Color,),
      labelSmall: TextStyle(color: AppColors.kNeutral10Color,),
      titleMedium: TextStyle(color: AppColors.kNeutral10Color,),
    ),

    dialogTheme: DialogThemeData(backgroundColor: AppColors.kNeutral100Color,contentTextStyle: TextStyle(color: AppColors.kNeutral10Color,)),
  );
}
