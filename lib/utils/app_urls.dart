import '../constants/constants.dart';


///  this class contains App Urls.
///  it helps to centralize all the urls.
///
class AppUrls {
  static String image_url = "https://qtljgttwigasqvkzeqxf.supabase.co/storage/v1/object/public/";
  static String gemini_url =  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GeminiApiKey}";
  static String base_url = InDevelopment ? 'https://generativelanguage.googleapis.com/v1beta/models' : "https://generativelanguage.googleapis.com/v1beta/models";


}