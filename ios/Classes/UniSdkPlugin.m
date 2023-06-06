//
//  UniSdkPlugin.m
//  uni_sdk_plugin
//
//  Created by Eric on 2023/6/6.
//

#import "UniSdkPlugin.h"
#import "DCUniMP.h"
#import "DCUniMPSDKEngine.h"

@interface UniSdkPlugin ()<DCUniMPSDKEngineDelegate>
@property (nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation UniSdkPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"uni_sdk_plugin" binaryMessenger:[registrar messenger]];
    UniSdkPlugin *instance = [[UniSdkPlugin alloc] init];
    instance.channel = channel;
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"%@", call.method);
    if ([call.method isEqualToString:@"openUniMP"]) {
        NSDictionary *arguments = call.arguments;
        [self beforeOpenUniMPWithAppId:arguments[@"appId"] url:arguments[@"url"] version:arguments[@"version"] result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)onUniMPEventReceive:(NSString *)appid event:(NSString *)event data:(id)data callback:(DCUniMPKeepAliveCallback)callback {
    if ([event isEqualToString:@"getUserInfo"]) {
        [self getUserInfoWithCallback:^(NSDictionary *userInfo) {
            if (userInfo) {
                NSString *uid = userInfo[@"uid"];
                NSString *token = userInfo[@"token"];
                callback(@{@"uid": uid, @"token": token}, NO);
            } else {
                callback(@{}, NO);
            }
        }];
    }
}

- (void)beforeOpenUniMPWithAppId:(NSString *)appid url:(NSString *)url version:(NSString *)version result:(FlutterResult)result {
    NSString *vnName = @"";
    NSDictionary *versionInfo = [DCUniMPSDKEngine getUniMPVersionInfoWithAppid:appid];
    if (versionInfo) {
        vnName = versionInfo[@"name"];
    }
    if ([DCUniMPSDKEngine isExistsUniMP:appid] && [vnName isEqualToString:version]) {
        [self openUniMPWithAppId:appid result:result];
    } else {
        NSString *filename = [[NSURL URLWithString:url] lastPathComponent];
        if (![self isFileExistsInDocuments:filename]) {
            __weak typeof(self) weakSelf = self;
            [self downloadFileAndSaveToDocumentsWithURL:[NSURL URLWithString:url] result:result completion:^{
                [weakSelf installAndOpenUniMPWithAppId:appid url:url result:result];
            }];
        }else{
            [self installAndOpenUniMPWithAppId:appid url:url result:result];
        }
    }
}

- (void)openUniMPWithAppId:(NSString *)appid result:(FlutterResult)result {
    DCUniMPConfiguration *config = [self getUniMPConfiguration];
    [DCUniMPSDKEngine openUniMP:appid configuration:config completed:^(DCUniMPInstance * _Nullable uniMPInstance, NSError * _Nullable error) {
        if (uniMPInstance) {
            NSLog(@"小程序打开成功");
            result(@(YES));
        } else {
            NSLog(@"%@", error);
            result(@(NO));
        }
    }];
}

- (void)installAndOpenUniMPWithAppId:(NSString *)appid url:(NSString *)url result:(FlutterResult)result {
    NSLog(@"install uni mp");
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [docsDir stringByAppendingPathComponent:[NSURL URLWithString:url].lastPathComponent];
    NSLog(@"%@", filePath);
    
    
    __weak typeof(self) weakSelf = self;
    NSError *installError = nil;
    [DCUniMPSDKEngine installUniMPResourceWithAppid:appid resourceFilePath:filePath password:nil error:&installError];
    if (!installError) {
        [weakSelf openUniMPWithAppId:appid result:result];
    } else {
        NSLog(@"load unimp error");
    }
}

- (DCUniMPConfiguration *)getUniMPConfiguration {
    DCUniMPConfiguration *config = [[DCUniMPConfiguration alloc] init];
    config.extraData = @{@"arguments": @"hello"};
    config.enableBackground = YES;
    return config;
}

//判断文件是否存在
- (BOOL)isFileExistsInDocuments:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:filename];
    
    return [fileManager fileExistsAtPath:fileURL.path];
}

- (void)downloadFileAndSaveToDocumentsWithURL:(NSURL *)url result:(FlutterResult)result completion:(dispatch_block_t)completion {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL *temporaryURL, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error downloading file: %@", error);
            result(@(NO));
            return;
        }
        
        if (temporaryURL) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *documentsURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
            NSURL *destinationURL = [documentsURL URLByAppendingPathComponent:url.lastPathComponent];
            
            NSError *moveError = nil;
            [fileManager moveItemAtURL:temporaryURL toURL:destinationURL error:&moveError];
            if (!moveError) {
                NSLog(@"File downloaded and saved to: %@", destinationURL.path);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            } else {
                result(@(NO));
                NSLog(@"Error saving file: %@", moveError);
            }
        } else {
            result(@(NO));
            NSLog(@"Temporary URL is nil.");
        }
    }];
    
    [task resume];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DCUniMPSDKEngine initSDKEnvironmentWithLaunchOptions:launchOptions];
    [DCUniMPSDKEngine setDelegate:self];
    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [DCUniMPSDKEngine applicationDidBecomeActive:application];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [DCUniMPSDKEngine applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [DCUniMPSDKEngine applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [DCUniMPSDKEngine applicationWillEnterForeground:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [DCUniMPSDKEngine destory];
}

- (void)getUserInfoWithCallback:(void (^)(NSDictionary *))callback {
    [self.channel invokeMethod:@"getUserInfo" arguments:nil result:^(id _Nullable result) {
        NSDictionary *userInfo = (NSDictionary *)result;
        callback(userInfo);
    }];
}

@end
