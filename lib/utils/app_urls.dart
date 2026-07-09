import '../constants/constants.dart';


///  this class contains App Urls.
///  it helps to centralize all the urls.
///
class AppUrls {
  static String get image_url => "$supabaseUrl/storage/v1/object/public/";
  static String get gemini_url {
    return "https://generativelanguage.googleapis.com/$geminiApiVersion/models/$geminiModel:generateContent";
  }
  static String get gemini_models_url =>
      "https://generativelanguage.googleapis.com/$geminiApiVersion/models";
  static String base_url = InDevelopment ? 'https://generativelanguage.googleapis.com/v1beta/models' : "https://generativelanguage.googleapis.com/v1beta/models";


}
