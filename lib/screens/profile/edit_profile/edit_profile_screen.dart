import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/controller/auth_controller.dart';
import 'package:proact/model/user_model.dart';
import 'package:proact/services/user_service.dart';
import 'package:proact/utils/app_urls.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  UserModel user = UserService.getCurrentUserData();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    _firstNameController.text =  user.firstName;
    _lastNameController.text =  user.lastName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey ,
            child: Column(
              children: [
                Obx(() {
                  ImageProvider imageProvider;

                  if (authController.imagePath.value.startsWith("https")) {
                    imageProvider = CachedNetworkImageProvider(authController.imagePath.value);
                  } else if (authController.imagePath.value.isNotEmpty) {
                    imageProvider = FileImage(File(authController.imagePath.value));
                  } else {
                    imageProvider = CachedNetworkImageProvider(user.photo);
                  }

                  return GestureDetector(
                    onTap: () async {
                      authController.pickAndUploadImage();
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: imageProvider,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Get.theme.iconTheme.color,
                            child: Icon(
                              Icons.edit,
                              color: Get.theme.scaffoldBackgroundColor,
                              size: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("${user.firstName} ${user.lastName}"),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  title: "First Name",
                  hintText: 'Your First Name',
                  icon: Icons.person,
                  controller: _firstNameController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  title: "Last Name",
                  hintText: 'Your Last Name',
                  icon: Icons.person_outline,
                  controller: _lastNameController,
                ),
                const SizedBox(height: 16),

              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar:Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                authController.editProfile(
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  photoUrl: authController.imagePath.value,
                );
              } else {
                Get.snackbar('Error', 'Please fill in all required fields correctly.');
              }
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

   Widget _buildTextField({
     required String hintText,
     required String title,
     required IconData icon,
     required TextEditingController controller,
   }) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(title, style: TextStyle(fontSize: 16)),
         SizedBox(height: 10),
         TextFormField(
           validator: (value) {
             if (value == null || value.trim().length < 3) {
               return "Enter ${hintText.toLowerCase()}";
             }
             return null;
           },
           style: TextStyle(fontSize: 18),
           controller: controller,
           decoration: InputDecoration(
             prefixIcon: Icon(icon, color: Colors.grey),
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


}
