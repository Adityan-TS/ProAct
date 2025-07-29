import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/services/user_service.dart';
import 'package:proact/utils/app_urls.dart';
import 'package:proact/utils/custom_image_picker.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user_model.dart';
import '../routes/routes.dart';
import '../utils/utils.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final tokenController = TextEditingController();
  final resetPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final client = Supabase.instance.client;
  final RxString imagePath = "${AppUrls.image_url}${HiveStoreUtil.getString(HiveStoreUtil.photo)}".obs;

  Future<void> pickAndUploadImage() async {
    File? file = await CustomImagePicker().pickProfilePicture();
    if(file != null){
      try {
        imagePath.value = file.path;
      } catch (e) {
        Get.snackbar('Error', 'Image upload failed: $e');
      }
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    Utils.showLoading();

    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final uid = response.user!.id;
        await UserService.checkUser(uid);
        Utils.closeLoading();
        Get.offAllNamed(Routes.homeScreen);
      } else {
        // Shouldn't really happen, but just in case
        Utils.closeLoading();
        Utils.showToast('Login failed. Please try again.');
      }
    } on AuthException catch (e) {
      Utils.closeLoading();

      // Friendly error messages
      if (e.message.contains('Invalid login credentials')) {
        Utils.showToast('Incorrect email or password.');
      } else {
        Utils.showToast('${e.message}');
      }
    } catch (e) {
      Utils.closeLoading();
      Utils.showToast('An unexpected error occurred: $e');
    }
  }

  Future<void> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    Utils.showLoading();

    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        final uid = user.id;

        final newUser = UserModel(
          userId: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          password: password,
          photo: '',
        );

        try {
          await UserService.insertUser(newUser);
        } catch (e) {
          // Insert into "Users" failed — show message
          Utils.showToast("Failed to save user profile: $e");
        }

        Utils.closeLoading();
        Get.offAllNamed(Routes.homeScreen);
      } else {
        Utils.closeLoading();
        Utils.showToast("Signup failed. Please try again.");
      }
    } on AuthException catch (e) {
      Utils.closeLoading();
      Utils.showToast("${e.message}");
    } catch (e) {
      Utils.closeLoading();
      Utils.showToast("Unexpected error: $e");
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final email = HiveStoreUtil.getString(HiveStoreUtil.emailKey);
    Utils.showLoading();

    try {
      // Step 1: Re-authenticate with old password
      final signInResponse = await client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      if (signInResponse.user == null) {
        Utils.closeLoading();
        print('❗ Old password is incorrect');
        return;
      }

      // Step 2: Change password in Auth
      final updateAuthResponse = await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (updateAuthResponse.user != null) {
        // Step 3: Update password field in 'Users' table too
        await UserService.updatePassword(newPassword, email);
        Utils.closeLoading();
        print('✅ Password updated successfully');
        Get.back();
      } else {
        Utils.closeLoading();
        print('❗ Failed to update password');
      }
    } catch (e) {
      Utils.closeLoading();
      print('❗ Exception while changing password: $e');
    }
  }

  Future<void> logout() async {
    Utils.showLoading();
    try {
      await Supabase.instance.client.auth.signOut();
      HiveStoreUtil.clear();
      Utils.closeLoading();
      Get.offAllNamed(Routes.loginScreen);
      print('✅ Logged out successfully');
    } catch (e) {
      Utils.closeLoading();
      print('❗ Logout failed: $e');
    }
  }

  Future<void> editProfile({
    required String firstName,
    required String lastName,
    required String photoUrl,
    String? newEmail, // optional new email
  }) async {
    Utils.showLoading();
    try {
      if(photoUrl.isNotEmpty && (!photoUrl.startsWith("https"))){
        final filePath = 'public/${DateTime.now().millisecond}.${photoUrl.split(".").last}';

        final uploadResponse = await Supabase.instance.client.storage
            .from('images')
            .upload(filePath, File(photoUrl));
        photoUrl = uploadResponse;
      } else {
        photoUrl = "images/${photoUrl.split("/images/").last}";
      }

      var response = await UserService.updateProfile(firstName: firstName, lastName: lastName, photoUrl: photoUrl, newEmail: newEmail);
      Get.back(result: true);
      Utils.closeLoading();

      if (response.error != null) {
        print('❗ Update profile error: ${response.error!.message}');
      } else {
        print('✅ Profile updated successfully');

        if (newEmail != null && newEmail.isNotEmpty) {
          // Update locally stored email
          HiveStoreUtil.setString(HiveStoreUtil.emailKey, newEmail);
        }
      }
    } catch (e) {
      Utils.closeLoading();
      print('❗ Exception while updating profile: $e');
    }
  }

  resetPasswordSend(){
    Get.back();
    final email = emailController.text.trim();
    Utils.showLoading(msg: "Check your email for token");

    Supabase.instance.client.auth
        .resetPasswordForEmail(email)
        .then((value) {
      Utils.closeLoading();
      Get.toNamed(Routes.resetPasswordScreen);
    }).catchError((error) {
      print("error");
    });
  }

  resetPassword()async{
    final password = resetPasswordController.text.trim();
    final email = emailController.text.trim();
    final token = tokenController.text.trim();
    Utils.showLoading(msg: "Resetting Password");
    // Perform login using Supabase
    try {
      final recovery = await client.auth
          .verifyOTP(
          email: email,
          token: token,
          type: OtpType.recovery);
      print(recovery);
      final response = await client.auth
          .updateUser(UserAttributes(password: password));

      print(response);
      if (response.user != null) {
        await client.auth
            .signOut(scope: SignOutScope.global);
        Utils.closeLoading();
        Get.back();
      } else {
        print('Reset password failed');
      }
    } catch (error) {
      Utils.closeLoading();
    }
  }
}