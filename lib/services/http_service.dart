import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:proact/constants/constants.dart';
import 'package:proact/utils/app_urls.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:proact/utils/utils.dart';

import '../routes/routes.dart';

// #region debug-point A:dbg-reporter
const String _dbgUrl =
    String.fromEnvironment('DEBUG_SERVER_URL', defaultValue: 'http://192.168.1.150:7777/event');
const String _dbgSessionId =
    String.fromEnvironment('DEBUG_SESSION_ID', defaultValue: 'proact-ai-not-working');
void _dbg(String hypothesisId, String location, String msg,
    [Map<String, Object?> data = const {}]) {
  () async {
    try {
      final payload = jsonEncode({
        'sessionId': _dbgSessionId,
        'runId': 'pre',
        'hypothesisId': hypothesisId,
        'location': location,
        'msg': msg,
        'data': data,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      final client = HttpClient();
      final req = await client.postUrl(Uri.parse(_dbgUrl));
      req.headers.contentType = ContentType.json;
      req.write(payload);
      await req.close();
      client.close();
    } catch (_) {}
  }();
}
// #endregion

/// HttpService class contains 4 main http request get,put,post,delete
/// in this class we have used interceptors, using those we can handle errors for all http requests.
/// Usage :
///   HttpService httpService = HttpService();
///   httpService.getRequest("url");

class HttpService {
  Dio _dio = Dio();

  HttpService() {
    _dio.options.followRedirects = true;
    _dio.options.validateStatus = (status) {
      return status! < 500;
    };
  }

// http get request
  Future getRequest(String url,{rowData = const {},bool useAuthorization = true,bool showLoading = false,closeLoading = false,}) async{
    _dio.options.headers['content-Type'] = 'application/json';
    if (url.contains('generativelanguage.googleapis.com')) {
      final key = geminiApiKey;
      if (key.isNotEmpty) {
        _dio.options.headers['x-goog-api-key'] = key;
      }
    }
    // if(useAuthorization) {
    //   _dio.options.headers['Authorization'] = "user ${HiveStoreUtil.getString(HiveStoreUtil.accessTokenKey)}";
    // }
    if(showLoading) Utils.showLoading();
    Response response;
    try {
      printLog("headers ${_dio.options.headers}" );
      printLog("url " + url);
      response = await _dio.get(url).catchError((e) => throw Exception(e));
      printLog("response.get ${response.data}");
      if(closeLoading) Utils.closeLoading();
      if(response.data?["status"] != null){
        if(response.data['status'] == 'failed'){
          if(response.data['message'].toString().toLowerCase().contains("token") && response.data['message'].toString().toLowerCase().contains("expired")){
            getx.Get.offAllNamed(Routes.loginScreen);
          }
          Utils.showToast(response.data['message'] ?? "");
        }
      }
    } catch (e) {
      printLog(e.toString());
      if(closeLoading) Utils.closeLoading();
      throw Exception(e);
    }

    return response;
  }

// http post request
  Future postRequest(String url,{rowData = const {},bool useAuthorization = true,bool showLoading = false,closeLoading = false,}) async{
    _dio.options.headers['content-Type'] = 'application/json';
    if (url.contains('generativelanguage.googleapis.com')) {
      final key = geminiApiKey;
      if (key.isEmpty) {
        if (closeLoading) Utils.closeLoading();
        Utils.showToast("Missing Gemini API key");
        // #region debug-point A:gemini-missing-key
        _dbg('A', 'http_service.dart:postRequest', '[DEBUG] gemini:missing_key');
        // #endregion
        throw Exception("Missing GEMINI_API_KEY");
      }
      _dio.options.headers['x-goog-api-key'] = key;
    }
    // if(useAuthorization) {
    //   _dio.options.headers['Authorization'] = "user ${HiveStoreUtil.getString(HiveStoreUtil.accessTokenKey)}";
    // }
    if(showLoading) Utils.showLoading();
    Response response;

    try {
      if(rowData is FormData){
        _dio.options.headers['Content-Type'] = "multipart/form-data";
        printLog("fields ${rowData.fields}");
        printLog("files ${rowData.files}");
      } else {
        printLog(jsonEncode(rowData));
      }
      printLog("headers ${_dio.options.headers}" );
      printLog("url ${url}");
      if (url.contains('generativelanguage.googleapis.com')) {
        final sanitizedUrl = url.replaceAll(RegExp(r'([?&]key=)[^&]+'), r'$1***');
        // #region debug-point A:gemini-request
        _dbg('A', 'http_service.dart:postRequest', '[DEBUG] gemini:request', {
          'url': sanitizedUrl,
          'headers': _dio.options.headers.map((k, v) => MapEntry(k, '$v')),
          'hasBody': rowData != null,
          'bodyType': rowData.runtimeType.toString(),
        });
        // #endregion
      }
      response = await _dio.post(url,data: rowData).catchError((e) => throw Exception(e));
      printLog("response.post ${response.data}");
      printLog("response.post ${response.statusCode}");
      if (url.contains('generativelanguage.googleapis.com')) {
        // #region debug-point A:gemini-response
        _dbg('A', 'http_service.dart:postRequest', '[DEBUG] gemini:response', {
          'statusCode': response.statusCode,
          'dataType': response.data.runtimeType.toString(),
          'dataPreview': ('${response.data}').substring(
            0,
            (('${response.data}').length > 800) ? 800 : ('${response.data}').length,
          ),
        });
        // #endregion
      }
      if(closeLoading) Utils.closeLoading();
      if(response.data?["status"] != null){
        if(response.data['status'] == 'failed'){
          if(response.data['message'].toString().toLowerCase().contains("token") && response.data['message'].toString().toLowerCase().contains("expired")){
            getx.Get.offAllNamed(Routes.loginScreen);
          }
          Utils.showToast(response.data['message'] ?? "");
        }
      }
    } catch (e) {
      if(closeLoading) Utils.closeLoading();
      printErrorLog(e.toString());
      if (url.contains('generativelanguage.googleapis.com')) {
        // #region debug-point A:gemini-exception
        _dbg('A', 'http_service.dart:postRequest', '[DEBUG] gemini:exception', {
          'error': e.toString(),
        });
        // #endregion
      }
      throw Exception(e);
    }

    return response;
  }

// http patch request
  Future patchRequest(String url,{rowData = const {},bool useAuthorization = true,}) async{
    _dio.options.headers['content-Type'] = 'application/json';
    Response response;
    if(useAuthorization) {
      _dio.options.headers['Authorization'] = "user ${HiveStoreUtil.getString(HiveStoreUtil.accessTokenKey)}";
    }
    try {
      printLog("headers ${_dio.options.headers}" );
      printLog("rowData.patch ${jsonEncode(rowData)}" );
      printLog("url $url");
      response = await _dio.patch(url,data: rowData);
      if(response.data?["status"] != null){
        if(response.data['status'] == 'failed'){
          if(response.data['message'].toString().toLowerCase().contains("token") && response.data['message'].toString().toLowerCase().contains("expired")){
            getx.Get.offAllNamed(Routes.loginScreen);
          }
          Utils.showToast(response.data['message'] ?? "");
        }
      }
      printLog("response.patch ${response.data}");
    } catch (e) {
      printLog(e.toString());
      throw Exception(e);
    }
    return response;
  }

  // http put request
  Future putRequest(String url,{rowData = const {},bool useAuthorization = true,bool showLoading = false,closeLoading = false,}) async{
    _dio.options.headers['content-Type'] = 'application/json';
    if(useAuthorization) {
      _dio.options.headers['Authorization'] = "user ${HiveStoreUtil.getString(HiveStoreUtil.accessTokenKey)}";
    }
    if(showLoading) Utils.showLoading();
    Response response;

    try {
      printLog("headers ${_dio.options.headers}" );
      printLog("url ${url}");
      printLog("rowData ${rowData}");
      response = await _dio.put(url,data: rowData).catchError((e) => throw Exception(e));
      printLog("response.put ${response.data}");
      if(closeLoading) Utils.closeLoading();
      if(response.data?["status"] != null){
        if(response.data['status'] == 'failed'){
          if(response.data['message'].toString().toLowerCase().contains("token") && response.data['message'].toString().toLowerCase().contains("expired")){
            getx.Get.offAllNamed(Routes.loginScreen);
          }
          Utils.showToast(response.data['message'] ?? "");
        }
      }
    } catch (e) {
      if(closeLoading) Utils.closeLoading();
      printErrorLog(e.toString());
      throw Exception(e);
    }

    return response;
  }

// http delete request
  Future deleteRequest(String url,{rowData = const {},bool useAuthorization = true,bool showLoading = false,closeLoading = false,}) async{
    _dio.options.headers['content-Type'] = 'application/json';
  if(useAuthorization) {
  _dio.options.headers['Authorization'] = "user ${HiveStoreUtil.getString(HiveStoreUtil.accessTokenKey)}";
  }
  if(showLoading) Utils.showLoading();
    Response response;
    try {
      printLog("headers ${_dio.options.headers}");
      printLog("url $url");
      printLog("rowData ${rowData}");
      response = await _dio.delete(url,data: rowData).catchError((e) => throw Exception(e));
      printLog("response.delete ${response.data}");
      printLog(response.toString());
    } catch (e) {
      if(closeLoading) Utils.closeLoading();
      printLog(e.toString());
      throw Exception(e);
    }

    return response;
  }

  initializeInterceptors(){
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onResponse: (e, handler) {
        handler.next(e);
      },
      onError: (e, handler) async {
        printLog("statusCode ${e.response?.statusCode.toString()}");
        printLog("error ${e.response?.data.toString()}");
        switch (e.response?.statusCode) {
          case 400: //Bad Request
            String msg = e.response?.data['message'] ??"";
            Utils.showToast(msg.isNotEmpty ? msg : "Something went wrong");
            break;
          case 401: // Not Authorized
            getx.Get.offAllNamed(Routes.loginScreen);
            String msg = e.response?.data['message'] ??"";
            Utils.showToast(msg.isNotEmpty ? msg :  "Something went wrong");
            break;
          case 404: // Not Found
            String msg = e.response?.data['message'] ??"";
            Utils.showToast(msg.isNotEmpty ? msg :  "Something went wrong");
            break;
          case 500: //Internal Server Error
            String msg = e.response?.data['message'] ??"";
            Utils.showToast(msg.isNotEmpty ? msg :  "Something went wrong");
            break;
          case 501: //Internal Server Error
            String msg = e.response?.data['message'] ??"";
            Utils.showToast(msg.isNotEmpty ? msg :  "Something went wrong");
            break;

          default:
            Utils.showToast("Something went wrong");
            break;
        }
        handler.next(e);
      },
    ));
  }

  void init() {
    _dio = Dio(BaseOptions(
        baseUrl: AppUrls.base_url,
        followRedirects: false,
        connectTimeout: Duration(minutes: 1), // 60 seconds
        receiveTimeout: Duration(minutes: 1)
    ));
    initializeInterceptors();
  }
}
