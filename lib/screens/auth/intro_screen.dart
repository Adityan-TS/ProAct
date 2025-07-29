import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/routes/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IntroScreen extends StatefulWidget {

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.centerLeft, // Align to the center left
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              35.0, 100.0, 35.0, 0), // Adjust position with padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start (left)
            children: [
              Text(
                "Let's Get",
                style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                // Use Poppins font and set color to white
              ),
              Text(
                'Started',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold, // Set fontWeight to bold
                  color:
                  Colors.white, // Use Poppins font and set color to white
                ),
              ),
              Text(
                'Fight Procrastination With Ease',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors
                        .white), // Use Poppins font and set color to white
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity, // Full width button
                padding: EdgeInsets.symmetric(
                    vertical: 7.5), // Smaller vertical padding
                margin: EdgeInsets.only(bottom: 16.0), // Margin between buttons
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  color: Colors.white, // Background color of the button
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.loginScreen);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.infinity, 0)), // Smaller height
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .transparent), // Transparent background for ElevatedButton
                    shadowColor: MaterialStateProperty.all<Color>(
                        Colors.transparent), // Transparent shadow
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                      ),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color(
                            0xFF1A1A1A), // Set button text color to #1a1a1a
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity, // Full width button
                padding: EdgeInsets.symmetric(
                    vertical: 7.5), // Smaller vertical padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  color: Color(0xFF1A1A1A), // Dark background color
                  border: Border.all(
                      color: Colors.white, width: 2.0), // White border
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.signupScreen);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.infinity, 0)), // Smaller height
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .transparent), // Transparent background for ElevatedButton
                    shadowColor: MaterialStateProperty.all<Color>(
                        Colors.transparent), // Transparent shadow
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                      ),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
