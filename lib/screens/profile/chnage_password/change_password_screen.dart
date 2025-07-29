import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/controller/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  AuthController controller = Get.put(AuthController());

  bool _currentPasswordObscureText = true;
  bool _newPasswordObscureText = true;
  bool _confirmPasswordObscureText = true;

  Widget _buildTextField({
    required bool obscureText,
    required String hintText,
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          style: const TextStyle(fontSize: 17),
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            ),
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                onToggleVisibility: () {
                  setState(() {
                    _currentPasswordObscureText = !_currentPasswordObscureText;
                  });
                },
                obscureText: _currentPasswordObscureText,
                hintText: 'Enter your current password',
                title: 'Current Password',
                icon: Icons.lock_outline,
                controller: _currentPasswordController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                onToggleVisibility: () {
                  setState(() {
                    _newPasswordObscureText = !_newPasswordObscureText;
                  });
                },
                obscureText: _newPasswordObscureText ,
                hintText: 'Enter new password',
                title: 'New Password',
                icon: Icons.lock,
                controller: _newPasswordController,
              ),
              const SizedBox(height: 20),
              _buildTextField(onToggleVisibility: () {
                setState(() {
                  _confirmPasswordObscureText = !_confirmPasswordObscureText;

                });
              },
                obscureText: _confirmPasswordObscureText,
                hintText: 'Confirm new password',
                title: 'Confirm Password',
                icon: Icons.lock,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
      bottomNavigationBar:  Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
           controller.changePassword(
               oldPassword: _currentPasswordController.text.trim().toString(),
               newPassword: _newPasswordController.text.trim().toString()
           );
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
