/*
 * @Descripttion: 
 * @version: 
 * @Author: niemengqiu
 * @Date: 2023-05-23 20:29:49
 * @LastEditors: niemengqiu
 * @LastEditTime: 2023-06-05 17:21:26
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_sdk_plugin/uni_sdk_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    UniSdkPlugin().setMethodCallHandler((call) async {
      switch (call.method) {
        case NativeCallMethod.getUserInfo:
          return {'uid': 12345, 'token': '1234567890'};
      }
    });
  }

  Future<void> openUniMP(BuildContext context) async {
    var flag = await UniSdkPlugin().openUniMP(
        "__UNI__EA8A35D",
        "https://xlttoss.dongdongchat.com/qfile/apps/microapp/__UNI__EA8A35D-1.0.0.wgt",
        "1.0.0");
    if (!flag) {
      _messangerKey.currentState?.showSnackBar(
          SnackBar(content: Text("小程序打开失败"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              openUniMP(context);
            },
            child: const Text('打开小程序'),
          ),
        ),
      ),
    );
  }
}
