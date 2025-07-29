import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proact/controller/auth_controller.dart';
import 'package:proact/controller/dashbord_controller.dart';
import 'package:proact/controller/theme_controller.dart';
import 'package:proact/model/user_model.dart';
import 'package:proact/routes/routes.dart';
import 'package:proact/services/user_service.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  ThemeController controller = Get.put(ThemeController());
  AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.all(8),
          icon : Icon(CupertinoIcons.back, color: Theme.of(context).iconTheme.color) ,
          onPressed: () => Get.back(),),
        title: const Text('PROFILE',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 27),),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          GetBuilder<DashboardController>(builder: (controller) {
            UserModel user = UserService.getCurrentUserData();

            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Stack(
                children: [
                  Container(
                    child: Row(
                      children: [
                        SizedBox(width: 170,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0,top: 20,right: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user.firstName} ${user.lastName}",style: TextStyle(fontSize: 15,color: Colors.white),),
                              SizedBox(height: 8,),
                              Text(user.email,style: TextStyle(fontSize: 13,color: Colors.white),),
                            ],
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 25),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(
                          user.photo.isNotEmpty
                              ? user.photo
                              :"https://www.manageengine.com/images/speaker-placeholder.png"),
                      radius: 70,
                    ),
                  ),
                ],
              ),
            );
          },),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: const Divider(color: Colors.grey,thickness: 0.2,),
          ),

          _buildTile(
            icon: Icons.person,
            title: 'My Profile',
            onTap: () async {
              var data = await Get.toNamed(Routes.editProfileScreen);
              if(data == true){
                DashboardController ctrl = Get.find();
                ctrl.update();
              }
            },
          ),
          _buildTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap:() {
            },
          ),
          _buildTile(
            icon: Icons.lock,
            title: 'Change Password',
            onTap:  () => Get.toNamed(Routes.changePasswordScreen),
          ),
          Obx(() => ListTile(
            leading: Icon(Icons.brightness_6, color: Theme.of(context).iconTheme.color),
            title: Text(
              'App Appearance',
              style: TextStyle(fontSize: 16,color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            trailing: CupertinoSwitch(
              activeColor: Colors.grey,
              value: controller.isDarkMode.value,
              onChanged: controller.toggleTheme,
            ),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: const Divider(color: Colors.grey,thickness: 0.2,),
          ),

          _buildTile(
            icon: Icons.share,
            title: 'Share App',
            onTap: ()  {
                Share.share(
                  'Check out this amazing app: https://play.google.com/store/apps/details?id=com.example.myapp',
                  subject: 'Awesome App',
                );

            },
          ),
          _buildTile(
            icon: Icons.star_rate,
            title: 'Rate us',
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton.icon(
          onPressed: () {
            showLogoutBottomSheet(context);
          },
          icon: Icon(Icons.logout, color: Colors.white),
          label: Text(
            'Log Out',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600,fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shadowColor: Colors.black.withOpacity(0.4),
            elevation: 10, // Higher elevation = deeper shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),

    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Theme.of(context).iconTheme.color),
          title: Text(title, style: TextStyle(fontSize:16,color: Theme.of(context).textTheme.bodyLarge?.color)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Divider(color: Colors.grey,thickness: 0.2,),
        ),
      ],
    );
  }
  void showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showDragHandle: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Log out',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to log out?',
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child:  Text('Cancel',style: TextStyle(color: Theme.of(context).textTheme.headlineMedium!.color),),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          authController.logout();
                        },
                        child: const Text(
                          'LOG OUT',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

} 
