import 'package:proact/utils/app_urls.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user_model.dart';
import '../utils/hive_store_util.dart';

class UserService {
  static var client = Supabase.instance.client;
  static var users = "Users";
  static var id = "id";
  static var email = "email";
  static var firstName = "first_name";
  static var lastName = "last_name";
  static var photo = "photo";
  static var password = "password";

  static checkUser(uid)async{
    final userResponse = await client
        .from(users)
        .select()
        .eq(id, uid)
        .single();

    HiveStoreUtil.setString(HiveStoreUtil.emailKey, userResponse[email] ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.userIdKey, uid);
    HiveStoreUtil.setString(HiveStoreUtil.firstNameKey, userResponse[firstName] ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.lastNameKey, userResponse[lastName] ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.photo, userResponse[photo] ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.password, userResponse[password] ?? '');

  }

  static insertUser(UserModel user)async{
    final insertResponse = await client
        .from(users)
        .insert(user.toMap());

    HiveStoreUtil.setString(HiveStoreUtil.emailKey, user.email ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.userIdKey, user.userId);
    HiveStoreUtil.setString(HiveStoreUtil.firstNameKey, user.firstName ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.lastNameKey, user.lastName ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.photo, user.photo ?? '');
    HiveStoreUtil.setString(HiveStoreUtil.password, user.password ?? '');
    return insertResponse;
  }

  static updatePassword(String newPassword,String email)async{

    final updateUserResponse = await client
        .from(UserService.users)
        .update({password: newPassword})
        .eq(email, email);
    return updateUserResponse;
  }

  static updateProfile({required String firstName,required String lastName,required String photoUrl,required String? newEmail})async{
    final currentEmail = HiveStoreUtil.getString(HiveStoreUtil.emailKey); // get logged-in user's current email
    // Prepare data to update
    Map<String, dynamic> updateData = {
      UserService.firstName: firstName,
      UserService.lastName: lastName,
      UserService.photo: photoUrl,
    };

    if (newEmail != null && newEmail.isNotEmpty) {
      updateData[email] = newEmail;
    }

    final response = await client
        .from(users)
        .update(updateData)
        .eq(email, currentEmail);
    HiveStoreUtil.setString(HiveStoreUtil.firstNameKey, firstName);
    HiveStoreUtil.setString(HiveStoreUtil.lastNameKey, lastName);
    HiveStoreUtil.setString(HiveStoreUtil.photo, photoUrl);
    return response;
  }

  static UserModel getCurrentUserData() {
    final email = HiveStoreUtil.getString(HiveStoreUtil.emailKey);
    final userId = HiveStoreUtil.getString(HiveStoreUtil.userIdKey);
    final firstName = HiveStoreUtil.getString(HiveStoreUtil.firstNameKey);
    final lastName = HiveStoreUtil.getString(HiveStoreUtil.lastNameKey);
    final photo = HiveStoreUtil.getString(HiveStoreUtil.photo).isNotEmpty ? "${AppUrls.image_url}${HiveStoreUtil.getString(HiveStoreUtil.photo)}" : "";
    final password = HiveStoreUtil.getString(HiveStoreUtil.password);

    return UserModel(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      photo: photo,
      password: password,
    );
  }

}