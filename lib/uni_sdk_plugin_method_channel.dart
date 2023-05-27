/*
 * @Descripttion: 
 * @version: 
 * @Author: niemengqiu
 * @Date: 2023-05-23 20:29:49
 * @LastEditors: niemengqiu
 * @LastEditTime: 2023-05-25 13:20:28
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'uni_sdk_plugin_platform_interface.dart';

/// An implementation of [UniSdkPluginPlatform] that uses method channels.
class MethodChannelUniSdkPlugin extends UniSdkPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('uni_sdk_plugin');

  MethodChannelUniSdkPlugin() {
    methodChannel.setMethodCallHandler((call) async {});
  }

  Future _methodChannelHandler(MethodCall call) async {
    switch (call.method) {
      case 'test':
        debugPrint("method channel handler test");
        debugPrint(call.arguments.toString());
        break;
      default:
        throw MissingPluginException();
    }
    return Future(() => null);
  }

  @override
  Future<String?> openUniMP(String appId, String url) async {
    final version = await methodChannel
        .invokeMethod<String>('openUniMP', {"appId": appId, "url": url});
    return version;
  }
}
