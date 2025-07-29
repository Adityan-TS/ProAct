import 'package:hive_flutter/hive_flutter.dart';

///  this class contains HiveStore communication.
///  it contains getter and setter function and also all storage keys.
///  because it helps to centralize all the storage related keys.

class HiveStoreUtil {
  static String accessTokenKey = "accessTokenKey";
  static String userIdKey = "userIdKey";
  static String emailKey = "emailKey";
  static String lastNameKey = "last_name";
  static String firstNameKey = "first_name";
  static String photo = "photo";
  static String password = "password";
  static const String passCode = "passCode";
  static const String splash = "splash";
  static const String lockedApps = 'lockedApps';
  static const String eventData = 'eventData';
  static var hiveBox = Hive.box('ProAct');

  static void setString(String key,String value){
    hiveBox.put(key, value);
  }

  static String getString(String key, {String defaultVal = ""}){
    return hiveBox.get(key,defaultValue: defaultVal);
  }

  static void setInt(String key,int value){
    hiveBox.put(key, value);
  }

  static int getInt(String key){
    return hiveBox.get(key,defaultValue: 0);
  }

  static setBool(String key,bool value){
    hiveBox.put(key, value);
  }

  static bool getBool(String key){
    return hiveBox.get(key,defaultValue: false);
  }

  static void setList(String key,List value){
    hiveBox.put(key, value);
  }

  static List getList(String key){
    return hiveBox.get(key,defaultValue: []);
  }

  static void setMap(String key,Map<String,dynamic> value){
    hiveBox.put(key, value);
  }

  static Map<String,dynamic> getMap(String key){
    return hiveBox.get(key,defaultValue: {}).cast<String, dynamic>();
  }

  static void clear(){
    setString(accessTokenKey, "");
    setString(userIdKey, "");
    setString(firstNameKey, "");
    setString(lastNameKey, "");
    setString(emailKey, "");
  }

}