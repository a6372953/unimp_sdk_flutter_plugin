package com.example.uni_sdk_plugin

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.dcloud.feature.sdk.DCSDKInitConfig
import io.dcloud.feature.sdk.DCUniMPSDK
import io.dcloud.feature.sdk.MenuActionSheetItem
import io.dcloud.feature.unimp.config.UniMPReleaseConfiguration

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.net.URL
import kotlin.concurrent.thread

/* UniSdkPlugin */
class UniSdkPlugin: FlutterPlugin, ActivityAware, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var ucontext: Context
  private lateinit var activity: Activity
  private var handler: Handler? = null
  // private lateinit var currentUniMP

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.d("uni sdk plugin","uni sdk plugin before init")
    ucontext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "uni_sdk_plugin")
    channel.setMethodCallHandler(this)

    //创建小程序右上角菜单项
    var sheetItems = listOf(
            MenuActionSheetItem("将小程序隐藏到后台", "enterBackground"),
            MenuActionSheetItem("关闭小程序", "closeUniMP"),
            MenuActionSheetItem("发送事件", "SendUniMPEvent")
    )

    //创建UniMP初始化配置
    var config = DCSDKInitConfig.Builder().setMenuActionSheetItems(sheetItems).build()

    //UniMP初始化
    DCUniMPSDK.getInstance().initialize(ucontext, config){isSuccess ->
      Log.d("DCUniMPSDK init","DCUniMPSDK init finished isSuccess $isSuccess")
    }
//    isInit = true
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
//    Log.d("method channel", "plugin is init $isInit")
    Log.d("method channel", "flutter method channel call ${call.method}")
//    if(!isInit){
//      channel.invokeMethod("test", "12345")
//      return
//    }
    if (call.method == "openUniMP") {
      //打开uni小程序
      val appId: String? = call.argument("appId")
      val url: String? = call.argument("url")
      Log.d("unimp load", "$appId, $url")
      if(appId != null && url != null){
        beforeOpenUniMP(appId, url, result)
      }else{
        result.error("1", "appid或者url不能为空", "appid或者url不能为空")
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    handler?.removeCallbacksAndMessages(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  fun beforeOpenUniMP(appid: String, url: String, @NonNull result: Result){
    checkNeedPermissions()

    var filePath = "${ucontext.cacheDir.path}$appid.wgt"
    if(DCUniMPSDK.getInstance().isExistsApp(appid)){
      //小程序已经存在，打开小程序
      Log.d("open unimp", "DCUniMPSDK.getInstance().openUniMP")
      DCUniMPSDK.getInstance().openUniMP(ucontext, appid)
      return
    }
    if(!fileIsExists(filePath)){

      Log.d("open unimp", "！fileIsExists")
      //缓存中文件夹中没有小程序，下载小程序
      if(handler == null){
        handler = object: Handler(Looper.getMainLooper()){
          override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
            when(msg.what){
              1 -> {
                Log.d("open unimp", "$appid,$filePath")
                openUniMP(appid, filePath, result)
              } else -> {
              //
            }
            }
          }
        }
      }

      var thread = Thread(){
        try{
          downloadFile(url, filePath)
          handler?.sendEmptyMessage(1)
        }catch(e:Exception){
          Log.d("download error", e.toString())
        }
      }
      thread.start()
    }else{
      //缓存文件夹中有小程序，打开小程序
      openUniMP(appid, filePath, result)
    }

  }

  fun openUniMP(appid: String,filePath: String, @NonNull result: Result){
    var uniMPReleaseConfiguration = UniMPReleaseConfiguration()
    uniMPReleaseConfiguration.wgtPath = filePath

    DCUniMPSDK.getInstance().releaseWgtToRunPath(appid, uniMPReleaseConfiguration){ code, pArgs->
      if(code == 1){
        //释放wgt完成
        try{
          //打开小程序
          DCUniMPSDK.getInstance().openUniMP(ucontext, appid)
        }catch (e: Exception){
          Log.d("unimp load","打开小程序失败,$e")
          result.error("1", e.message, e.toString())
        }
      }else{
        Log.d("unimp load", "释放wgt失败,code:$code,pargs:$pArgs")
        //释放wgt失败
        result.error("1", "小程序获取失败,code:$code,msg:$pArgs", "小程序获取失败,code:$code,msg:$pArgs")
      }
    }
  }

  fun fileIsExists(filePath: String): Boolean {
    try {
      val f = File(filePath)
      if (!f.exists()) {
        return false
      }
    } catch (e: java.lang.Exception) {
      return false
    }
    return true
  }

  fun downloadFile(url: String,filePath: String){
    var url = URL(url)
    var connection = url.openConnection()
    var input = BufferedInputStream(connection.getInputStream())

    var output = FileOutputStream(filePath)
    val data = ByteArray(1024)
    var count: Int
    while (input.read(data).also { count = it } != -1) {
      output.write(data, 0, count)
    }
    output.flush()
    output.close()
    input.close()
  }

  fun checkNeedPermissions(){
    if(ContextCompat.checkSelfPermission(ucontext, android.Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED || ContextCompat.checkSelfPermission(ucontext, android.Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED){
      //申请权限
      ActivityCompat.requestPermissions(activity, arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE,android.Manifest.permission.READ_EXTERNAL_STORAGE),1)
    }
  }
}
