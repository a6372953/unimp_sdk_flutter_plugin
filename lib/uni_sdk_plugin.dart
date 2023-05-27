/*
 * @Descripttion: 
 * @version: 
 * @Author: niemengqiu
 * @Date: 2023-05-23 20:29:49
 * @LastEditors: niemengqiu
 * @LastEditTime: 2023-05-24 19:53:35
 */
import 'uni_sdk_plugin_platform_interface.dart';

class UniSdkPlugin {
  static final UniSdkPlugin _instance = UniSdkPlugin._();
  factory UniSdkPlugin() {
    return _instance;
  }
  UniSdkPlugin._();

  Future<String?> openUniMP(String appId, String url) {
    return UniSdkPluginPlatform.instance.openUniMP(appId, url);
  }
}
