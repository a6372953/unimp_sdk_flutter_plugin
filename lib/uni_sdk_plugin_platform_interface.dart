/*
 * @Descripttion: 
 * @version: 
 * @Author: niemengqiu
 * @Date: 2023-05-23 20:29:49
 * @LastEditors: niemengqiu
 * @LastEditTime: 2023-06-05 09:50:25
 */
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'uni_sdk_plugin_method_channel.dart';

abstract class UniSdkPluginPlatform extends PlatformInterface {
  /// Constructs a UniSdkPluginPlatform.
  UniSdkPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static UniSdkPluginPlatform _instance = MethodChannelUniSdkPlugin();

  /// The default instance of [UniSdkPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUniSdkPlugin].
  static UniSdkPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UniSdkPluginPlatform] when
  /// they register themselves.
  static set instance(UniSdkPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> openUniMP(String appId, String url, String version) {
    throw UnimplementedError('openUniMP() has not been implemented.');
  }

  void setMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) async {
    throw UnimplementedError(
        'setMethodCallHandler() has not been implemented.');
  }
}
