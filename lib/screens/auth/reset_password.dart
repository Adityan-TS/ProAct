import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/controller/auth_controller.dart';
import 'package:proact/utils/utils.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPassword extends StatefulWidget {

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _resetPasswordformKey = GlobalKey<FormState>();
  AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white),
          child: Form(
            key: _resetPasswordformKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller.tokenController,
                  decoration: InputDecoration(
                    labelText: 'Otp Token',
                    hintStyle: TextStyle(color: Colors.grey),
                    fillColor: Color(0xFFf1f5f9),
                    filled: true,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14,),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your otp token';
                    } else if (value.length != 6) {
                      return 'Otp token should be 6 digit code';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5),
                TextFormField(
                  controller: controller.resetPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    fillColor: Color(0xFFf1f5f9),
                    filled: true,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14,),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value != controller.confirmPasswordController.text) {
                      return 'Password doesn\'t match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5),
                TextFormField(
                  controller: controller.confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    fillColor: Color(0xFFf1f5f9),
                    filled: true,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14,),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value != controller.resetPasswordController.text) {
                      return 'Confirm Password doesn\'t match';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_resetPasswordformKey.currentState!.validate()) {
                      controller.resetPassword();
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all<Size>(
                        Size(double.infinity, 50)),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF1A1A1A)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: 55,
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
