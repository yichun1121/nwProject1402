//
//  nwAppDelegate.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "nwAppDelegate.h"

@implementation nwAppDelegate

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler {
	self.backgroundSessionCompletionHandler = completionHandler;
    
    //add notification
    [self presentNotification];
}

-(void)presentNotification{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"Download Complete!";
    localNotification.alertAction = @"Background Transfer Download!";
    
    //On sound
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    //increase the badge number of application plus 1
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

#pragma mark - 在這裡檢查要不要copy一份plist到document裡面
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //取得檔案路徑
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/CustFavorite.plist"];
    //檢查檔案如果不存在，複製一份
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: filePath]){
        NSString *sysPlistPath=[[NSBundle mainBundle] pathForResource:@"Favorite" ofType:@"plist"];
        //if ([fileManager isReadableFileAtPath:filePath] )
        [fileManager copyItemAtPath:sysPlistPath toPath:filePath error:nil];
        NSLog(@"copy system favorite file to %@",filePath);
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
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
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
