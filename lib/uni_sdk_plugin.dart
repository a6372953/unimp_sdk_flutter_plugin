/*
 * @Descripttion: 
 * @version: 
 * @Author: niemengqiu
 * @Date: 2023-05-23 20:29:49
 * @LastEditors: niemengqiu
 * @LastEditTime: 2023-06-07 16:18:28
 */
import 'package:flutter/services.dart';

import 'uni_sdk_plugin_platform_interface.dart';

class UniSdkPlugin {
  static final UniSdkPlugin _instance = UniSdkPlugin._();
  factory UniSdkPlugin() {
    return _instance;
  }
  UniSdkPlugin._();

  void setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    UniSdkPluginPlatform.instance.setMethodCallHandler(handler);
  }

  Future<bool> openUniMP(String appId, String url, String version,
      {String? scene}) {
    return UniSdkPluginPlatform.instance
        .openUniMP(appId, url, version, scene: scene);
  }
}

class NativeCallMethod {
  /// 获取用户信息
  static const String getUserInfo = "getUserInfo";
}
