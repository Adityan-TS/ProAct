import 'package:flutter/material.dart';
import 'package:proact/custom_elements/custom_elements.dart';

abstract class AppColors {
  //-------------Primary Colors-------------//
  static const kPrimaryColor = Color(0xFF25AB70);
  static const kPrimarySurfaceColor = Color(0xFFE6F6EE);
  static const kPrimaryBorderColor = Color(0xFF7EB59C);
  static const kPrimaryFocusColor = Color(0xFF25AB70);
  //-------------Neutral Colors-------------//
  static const kNeutral10Color = Color(0xFFFFFFFF);
  static const kNeutral20Color = Color(0xFFF6F6F6);
  static const kNeutral30Color = Color(0xFFE8E8E8);
  static const kNeutral40Color = Color(0xFFDDDDDD);
  static const kNeutral50Color = Color(0xFFD2D2D2);
  static const kNeutral60Color = Color(0xFFD2D2D2);
  static const kNeutral70Color = Color(0xFFA4A4A4);
  static const kNeutral80Color = Color(0xFF777777);
  static const kNeutral90Color = Color(0xFF494949);
  static const kNeutral100Color = Color(0xFF1C1C1C);

  //-----------Danger Color-----------//
  static const Color kDanger1 = Color(0xFFFF3B30);
  static const Color kDanger2 = Color(0xFFFFD8D6);
  static const Color kDanger3 = Color(0xFFFFBEBA);
  static const Color kDanger4 = Color(0xFFD53128);
  static const Color kDanger5 = Color(0xFF801D18);
  static final Color kDanger6 = const Color(0xFFFF3B30).withOpacity(0.2);

  //-----------Warning Color-----------//
  static const Color kWarning1 = Color(0xFFFE6E28);
  static const Color kWarning2 = Color(0xFFFFF0EB);
  static const Color kWarning3 = Color(0xFFFFCAB9);
  static const Color kWarning4 = Color(0xFFCAA73F);
  static const Color kWarning5 = Color(0xFF796426);
  static final Color kWarning6 = const Color(0xFFFE6E28).withOpacity(0.20);

  //Other Colors
  static const Color kWhite = kNeutral10Color;
  static const kblack= Color(0xff000000);


}

//Maan Text Styles
class AppTextStyle {
  static final kHeading1 = TextStyle(
      color: AppColors.kNeutral100Color,
      fontSize: 30.sp,
      fontWeight: FontWeight.w700);
  static final kHeading2 = TextStyle(
      color: AppColors.kNeutral100Color,
      fontSize: 24.sp,
      fontWeight: FontWeight.w700);
  static final kHeading3 = TextStyle(
      color: AppColors.kNeutral100Color,
      fontSize: 20.sp,
      fontWeight: FontWeight.w700);

  static final kBodyLg = TextStyle(
      color: AppColors.kNeutral100Color,
      fontSize: 18.sp);

  static final kBodyMd = TextStyle(
      color: AppColors.kNeutral100Color,
      fontSize: 16.sp);

  static final kBodySm = TextStyle(
      color: AppColors.kNeutral100Color,
      fontSize: 15.sp);
  static final kCaption = TextStyle(
      color: AppColors.kNeutral100Color,
      fontSize: 12.sp);
}

//Maan Button Styles
class AppButtonStyle {
  static final kPrimaryTextButton = ButtonStyle(
    textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
    minimumSize: WidgetStatePropertyAll(Size(366.w, 50.h)),
    backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
    foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    )),
  );
  static final kSecondaryButton = ButtonStyle(
      textStyle: WidgetStatePropertyAll(TextStyle( fontSize: 16.sp, fontWeight: FontWeight.w500)),
      foregroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
      minimumSize: WidgetStatePropertyAll(Size(366.w, 50.h)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          side: BorderSide(color: AppColors.kPrimaryColor, width: 1.5.w),
          borderRadius: BorderRadius.circular(30))));

  static final kTertiaryButton = ButtonStyle(
    textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 16.sp)),
    minimumSize: WidgetStatePropertyAll(Size(366.w, 50.h)),
    backgroundColor:
    WidgetStatePropertyAll(AppColors.kDanger1.withOpacity(0.1)),
    foregroundColor: WidgetStatePropertyAll<Color>(AppColors.kDanger1),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    )),
  );
}

//Input Decoration
class AppInputDecoration {
  static final InputDecoration kInputDecoration = InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintStyle:
      AppTextStyle.kBodyMd.copyWith(color: AppColors.kNeutral80Color),
      floatingLabelStyle:
      AppTextStyle.kBodySm.copyWith(color: AppColors.kNeutral100Color),
      isDense: true,
      labelStyle: AppTextStyle.kBodyMd
          .copyWith(color: AppColors.kNeutral80Color, fontSize: 16.sp),

      //Enabled Border
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide:
          BorderSide(color: AppColors.kNeutral30Color, width: 1.w)),

      //Focus Border
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide:
          BorderSide(color: AppColors.kNeutral90Color, width: 1.w)),

      //Error Border
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: AppColors.kDanger1, width: 1.w)),

      //Error Focus Border
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: AppColors.kDanger1, width: 1.w)),

      //Suffix Icon Color
      suffixIconColor: AppColors.kNeutral80Color);

  static const kUnstyledInputDecoration = InputDecoration(
      border: OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide.none),
      errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      contentPadding: EdgeInsets.zero);

  static final InputDecoration kSearchInput = InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintStyle:
      AppTextStyle.kBodyMd.copyWith(color: AppColors.kNeutral80Color),
      floatingLabelStyle:
      AppTextStyle.kBodySm.copyWith(color: AppColors.kNeutral100Color),
      isDense: true,
      labelStyle: AppTextStyle.kBodyMd
          .copyWith(color: AppColors.kNeutral80Color, fontSize: 16.sp),

      //Enabled Border
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: const BorderSide(color: Colors.transparent, width: 0)),

      //Disabled Border
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: const BorderSide(color: Colors.transparent, width: 0)),

      //Focus Border
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
          borderSide: const BorderSide(color: Colors.transparent, width: 0)),

      //Error Border
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
          borderSide: const BorderSide(color: Colors.transparent, width: 0)),

      //Error Focus Border
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
          borderSide: const BorderSide(color: Colors.transparent, width: 0)),

      //Suffix Icon Color
      suffixIconColor: AppColors.kNeutral80Color);
}