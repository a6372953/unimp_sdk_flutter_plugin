import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let options = NSMutableDictionary.init(dictionary: launchOptions ?? [:])
              options.setValue(NSNumber.init(value:true), forKey: "debug")
              DCUniMPSDKEngine.initSDKEnvironment(launchOptions: options as! [AnyHashable : Any]);
              
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    //app生命周期
    override func applicationDidBecomeActive(_ application: UIApplication) {
        DCUniMPSDKEngine.applicationDidBecomeActive(application)
    }
    override func applicationWillResignActive(_ application: UIApplication) {
        DCUniMPSDKEngine.applicationWillResignActive(application)
    }
    override func applicationDidEnterBackground(_ application: UIApplication) {
        DCUniMPSDKEngine.applicationDidEnterBackground(application)
    }
    override func applicationWillEnterForeground(_ application: UIApplication) {
        DCUniMPSDKEngine.applicationWillEnterForeground(application)
    }
    override func applicationWillTerminate(_ application: UIApplication) {
        DCUniMPSDKEngine.destory()
    }
}
