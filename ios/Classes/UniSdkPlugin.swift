import Flutter
import UIKit

public class UniSdkPlugin: NSObject, FlutterPlugin, DCUniMPSDKEngineDelegate {
            
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "uni_sdk_plugin", binaryMessenger: registrar.messenger())
        let instance = UniSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        print(call.method)
        if(call.method == "openUniMP"){
            let arguments = call.arguments as! Dictionary<String, Any>
            beforeOpenUniMP(appid: arguments["appId"] as! String, url: arguments["url"] as! String, result: result)
        }else{
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func onUniMPEventReceive(_ appid: String, event: String, data: Any, callback: @escaping DCUniMPKeepAliveCallback) {
        //监听小程序发送事件
        if(event == "getUserInfo"){
            callback([
                "uid": 123,
                "token": "2333"
            ], false)
        }
    }
    
    private func beforeOpenUniMP(appid: String, url: String, result: @escaping FlutterResult){
        //打开小程序
        //判断小程序是否已存在
        if(DCUniMPSDKEngine.isExistsUniMP(appid)){
            openUniMP(appid: appid, result: result)
        }else{
            if(!isFileExistsInDocuments(filename: appid+".wgt")){
                //下载文件
                downloadFileAndSaveToDocuments(url: URL(string: url)!, result: result){ [weak self] in
                    print("file download success")
                    self?.installAndOpenUniMP(appid: appid, result: result)
                }
            }else{
                installAndOpenUniMP(appid: appid, result: result)
            }
        }
    }
    
    func openUniMP(appid: String, result: @escaping FlutterResult) {
        let config = self.getUniMPConfiguration()
        DCUniMPSDKEngine.openUniMP(appid, configuration: config) { instance, error in
            if instance != nil {
                print("小程序打开成功")
                //self.uniMPInstance = instance
                result(true)
            } else {
                print(error as Any)
                result(false)
            }
        }
    }
    
    func installAndOpenUniMP(appid: String, result: @escaping FlutterResult){
        print("install uni mp")
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = docsDir + "/" + appid + ".wgt"
        print(filePath)
        
        
        do{try DCUniMPSDKEngine.installUniMPResource(withAppid: appid, resourceFilePath: filePath, password: nil)
            self.openUniMP(appid: appid, result: result)
        }catch{
            print("load unimp error")
        }
        
    }
    
    func getUniMPConfiguration()->DCUniMPConfiguration{
        let config = DCUniMPConfiguration.init()
        config.extraData = ["arguments": "hello"]
        config.enableBackground = true
        return config
    }
    
    //判断文件是否存在
    func isFileExistsInDocuments(filename: String) -> Bool {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func downloadFileAndSaveToDocuments(url: URL, result: @escaping FlutterResult, completion:@escaping ()->Void) {
        //下载文件
        let session = URLSession.shared
        
        let task = session.downloadTask(with: url) { (temporaryURL, response, error) in
            if let error = error {
                print("Error downloading file: \(error)")
                result(false)
                return
            }
            
            guard let temporaryURL = temporaryURL else {
                print("Temporary URL is nil.")
                result(false)
                return
            }
            
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            
            do {
                try fileManager.moveItem(at: temporaryURL, to: destinationURL)
                print("File downloaded and saved to: \(destinationURL.path)")
                DispatchQueue.main.sync {
                    completion()
                }
            } catch {
                result(false)
                print("Error saving file: \(error)")
            }
        }
        
        task.resume()
    }
}
