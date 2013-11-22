//
//  AppDelegate.m
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "AppDelegate.h"
#import "IdentityCore.h"
#import "LocationCore.h"
#import "UserManager.h"
#import "Security.h"

#import "DDLog.h"
#import "DDFileLogger.h"

#import "SetupViewController.h"

#import "MeViewController.h"
#import "MapViewController.h"
#import "SettingsViewController.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface AppDelegate(){
    DDFileLogger                *_fileLogger;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _fileLogger = [[DDFileLogger alloc] init];
    _fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    _fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:_fileLogger];
    DDLogVerbose(@"didFinishLaunchingWithOptions:%@",launchOptions);
    NSArray *peripheralManagerArray = launchOptions[UIApplicationLaunchOptionsBluetoothPeripheralsKey];
    for (NSString *identify in peripheralManagerArray) {
        if ([identify isEqualToString:@"Oltica-Identity-PM"]) {
            DDLogVerbose(@"FoundIdentity");
        }
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([[UserManager defaultManager]isAuthed]) {
        [self presentMainUI];
    }else{
        //Present Login UI
        /*[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishLogin) name:@"DidLogin" object:nil];
        self.window.rootViewController = [[SetupViewController alloc]initWithNibName:nil bundle:nil];
        [self.window makeKeyAndVisible];*/
        //Demo only
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isLogin"];
        [[NSUserDefaults standardUserDefaults]setObject:@"7219480F-90F9-4663-8491-0282CE8E8D0E" forKey:@"UUID"];
        [[NSUserDefaults standardUserDefaults]setObject:@"Zelous" forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults]setObject:@"http://dl.ti.io/narcissus/zelous_avatar.png" forKey:@"userAvatar"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [Security setName:@"OTPSec" WithContent:@"B2374TNIQ3HKC446"];
        [[UserManager defaultManager]reinit];
        [self presentMainUI];
    }
    
    // Override point for customization after application launch.
    return YES;
}

- (void)presentMainUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MeViewController *meViewController = [[MeViewController alloc] initWithNibName:@"MeView" bundle:nil];
        MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:nil bundle:nil];
        //SettingsViewController *settingsViewController = [[SettingsViewController alloc]initWithNibName:nil bundle:nil];
        
        self.tabBarController = [[UITabBarController alloc] init];
        self.tabBarController.viewControllers = @[meViewController, mapViewController/*, settingsViewController*/];
        self.window.rootViewController = self.tabBarController;
        [self.window makeKeyAndVisible];
        [IdentityCore defaultCore];
        [LocationCore defaultCore];
    });
}

- (void)didFinishLogin
{
    [self presentMainUI];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogVerbose(@"EnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogVerbose(@"Terminated");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
