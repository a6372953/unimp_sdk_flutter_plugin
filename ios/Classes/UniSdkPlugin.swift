import Flutter
import UIKit

public class UniSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "uni_sdk_plugin", binaryMessenger: registrar.messenger())
        let instance = UniSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print(call.method)
        if(call.method == "openUniMP"){
            let arguments = call.arguments as! Dictionary<String, Any>
            beforeOpenUniMP(appid: arguments["appId"] as! String, url: arguments["url"] as! String)
        }else{
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func beforeOpenUniMP(appid: String, url: String){
        //打开小程序
        //判断小程序是否已存在
        if(DCUniMPSDKEngine.isExistsUniMP(appid)){
            openUniMP(appid: appid)
        }else{
            if(!isFileExistsInDocuments(filename: appid+".wgt")){
                //下载文件
                downloadFileAndSaveToDocuments(url: URL(string: url)!){ [weak self] in
                    print("file download success")
                    self?.installAndOpenUniMP(appid: appid)
                    
                }
            }else{
                installAndOpenUniMP(appid: appid)
            }
        }
    }
    
    func openUniMP(appid: String){
        let config = self.getUniMPConfiguration()
        DCUniMPSDKEngine.openUniMP(appid, configuration: config) { instance, error in
            if instance != nil {
                print("小程序打开成功")
                //                                    self.uniMPInstance = instance
            } else {
                print(error as Any)
            }
        }
    }
    
    func installAndOpenUniMP(appid: String){
        print("install uni mp")
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = docsDir + "/" + appid + ".wgt"
        print(filePath)
        
        
        do{try DCUniMPSDKEngine.installUniMPResource(withAppid: appid, resourceFilePath: filePath, password: nil)
            self.openUniMP(appid: appid)
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
    
    func downloadFileAndSaveToDocuments(url: URL, completion:@escaping ()->Void) {
        //下载文件
        let session = URLSession.shared
        
        let task = session.downloadTask(with: url) { (temporaryURL, response, error) in
            if let error = error {
                print("Error downloading file: \(error)")
                return
            }
            
            guard let temporaryURL = temporaryURL else {
                print("Temporary URL is nil.")
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
                print("Error saving file: \(error)")
            }
        }
        
        task.resume()
    }
}
