import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/controller/auth_controller.dart';
import 'package:proact/screens/auth/widget/common_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.poppins(fontSize: 14,), // Poppins font for app bar title
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50,),
              Text(
                'Sign Up',
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Please enter an email address and password to create your account.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonTextField(
                      label: "First Name",
                      controller: controller.firstNameController,
                      hintText: "First name",
                      validator: (value) {

                      },
                    ),
                    SizedBox(height: 15),
                    CommonTextField(
                      label: "Last Name",
                      controller: controller.lastNameController,
                      hintText: "Last name",
                      validator: (value) {

                      },
                    ),
                    SizedBox(height: 15),
                    CommonTextField(
                      label: "Email Address",
                      controller: controller.emailController,
                      hintText: "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    CommonTextField(
                      obscureText: true,
                      label: "Password",
                      controller: controller.passwordController,
                      hintText: "Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          controller.signup();
                        }
                      },
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all<Size>(
                            Size(double.infinity, 50)), // Full width button
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Color(0xff000000)), // Black background color
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                          ),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 55, // Set a fixed height for consistency
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white, // White text color
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Navigate back to LoginScreen
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(fontSize: 13,color: Theme.of(context).iconTheme.color)

                                ),
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                      color: Theme.of(context).iconTheme.color

                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
