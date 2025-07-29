import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:proact/constants/constants.dart';
import 'package:proact/utils/app_urls.dart';
import 'package:proact/utils/hive_store_util.dart';
import 'package:proact/utils/utils.dart';

import '../routes/routes.dart';

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
      response = await _dio.post(url,data: rowData).catchError((e) => throw Exception(e));
      printLog("response.post ${response.data}");
      printLog("response.post ${response.statusCode}");
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