//
//  AppDelegate.m
//  ESAYCAM
//
//  Created by Sept on 16/5/3.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "AppDelegate.h"

#import "JYHomeController.h"
#import "JYNewFetureViewCtl.h"
#import "JYNavigationController.h"
#import "AFNetworking.h"

@interface AppDelegate ()

@property (nonatomic,strong) NSMutableDictionary *versionDcit;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [self getAppStoreVersion];
    
    [UIApplication sharedApplication].idleTimerDisabled =YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // 取出沙盒中存储的上次使用软件的版本号
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"CFBundleShortVersionString"];
    
    // 获得当前软件的版本号
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    fun(currentVersion);
    if ([currentVersion isEqualToString:lastVersion]) {
        // 显示状态栏
        application.statusBarHidden = NO;
        
        JYNavigationController *navCtl = [[JYNavigationController alloc] initWithRootViewController:[[JYHomeController alloc] init]];
        
        self.window.rootViewController = navCtl;
        
    } else { // 新版本
        UINavigationController *navCtl = [[UINavigationController alloc] initWithRootViewController:[[JYNewFetureViewCtl alloc] init]];
        
        self.window.rootViewController = navCtl;
        // 存储新版本
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"CFBundleShortVersionString"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)getAppStoreVersion
{
    NSMutableDictionary *versionDcit = [NSMutableDictionary dictionary];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"http://itunes.apple.com/lookup?id=1115965900" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject valueForKey:@"resultCount"] intValue]>0) {
            
            [versionDcit setValue:@"1" forKey:@"status"];
            [versionDcit setValue:[[[responseObject valueForKey:@"results"] objectAtIndex:0] valueForKey:@"version"]   forKey:@"version"];
        }
        [JYSeptManager sharedManager].versionDict = versionDcit;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (BOOL)application:(UIApplication *)application

shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    if ([extensionPointIdentifier isEqualToString:@"com.apple.keyboard-service"]) {
        
        return NO;
    }
    return YES;
    
}

void fun(NSString *str)
{
    NSString *versionStr = [str stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    [JYSeptManager sharedManager].version = [versionStr integerValue];
}

//应用程序将要退出，通常用于保存书架和一些推出前的清理工作，
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

//应用程序已经进入后台运行
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 断开蓝牙连接
//    [[JYSeptManager sharedManager].blueManager disconnect:[JYSeptManager sharedManager].blueManager.connectPeripheral];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

@end
