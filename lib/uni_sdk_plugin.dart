/*
 * @Descripttion: 
 * @version: 
 * @Author: niemengqiu
 * @Date: 2023-05-23 20:29:49
 * @LastEditors: niemengqiu
 * @LastEditTime: 2023-06-02 14:57:47
 */
import 'uni_sdk_plugin_platform_interface.dart';

class UniSdkPlugin {
  static final UniSdkPlugin _instance = UniSdkPlugin._();
  factory UniSdkPlugin() {
    return _instance;
  }
  UniSdkPlugin._();

  Future<bool> openUniMP(String appId, String url) {
    return UniSdkPluginPlatform.instance.openUniMP(appId, url);
  }
}
