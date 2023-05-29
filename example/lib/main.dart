/*
 * @Descripttion: 
 * @version: 
 * @Author: niemengqiu
 * @Date: 2023-05-23 20:29:49
 * @LastEditors: niemengqiu
 * @LastEditTime: 2023-05-29 17:29:36
 */
import 'package:flutter/material.dart';
import 'dart:async';

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
  @override
  void initState() {
    super.initState();
  }

  Future<void> openUniMP() async {
    try {
      await UniSdkPlugin().openUniMP("__UNI__73C71A0",
              "https://voice-images.oss-cn-beijing.aliyuncs.com/test/wgt/__UNI__73C71A0.wgt") ??
          'Unknown platform version';
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              openUniMP();
            },
            child: const Text('打开小程序'),
          ),
        ),
      ),
    );
  }
}
