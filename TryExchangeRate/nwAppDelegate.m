//
//  nwAppDelegate.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "nwAppDelegate.h"
#import "ParseTaiwanBank.h"
#import "RateListTVC.h"
@interface nwAppDelegate()
@end
@implementation nwAppDelegate{
    int stepCount;
    NSURL *destinationURL;
}
@synthesize twBank=_twBank;
@synthesize dateFormatter=_dateFormatter;
-(NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter=[NSDateFormatter new];
        _dateFormatter.dateFormat=@"MM/dd HH:mm:ss";
    }
    return _dateFormatter;
}
-(ParseTaiwanBank *)twBank{
    if (!_twBank) {
        _twBank=[ParseTaiwanBank new];
    }
    return _twBank;
}
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
    
    self.session = [self backgroundSession];
    
    [self checkFavoriteList];
    [self checkRateFile];
    
    return YES;
}
/*! 設定NSURLSession.delegate=self（在viewDidLoad的時候就設好session了）
 */
- (NSURLSession *)backgroundSession {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"backgroundSession",@"pre 2");
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}
#pragma mark - 2 應該是check progress bar的過程
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite",@"2");
    if (downloadTask == self.downloadTask) {
        //更新進度條...
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progressView.progress = progress;
        });
        NSLog(@"step # %i %@ ----- %@",++stepCount,@"downloadTask == self.downloadTask",@"2");
    }
}


#pragma mark - 3 下載過程結束。
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSession:downloadTask:didFinishDownloadingToURL:",@"3");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //手機APP裡的document資料夾（URLs的第0個就是了）
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    //原始完整網址
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    // NEWCODE - ivar instead of property
    //拷貝後完整網址（資料夾+原始網址最後的檔名）
    destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
        
        // NEWCODE
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progressView.hidden = YES;
            
            //download完後開始處理字串
            NSString *htmlString=[self readFileIntoString:destinationURL];
            [self pickCurrencyAndRateUpFromHtmlString:htmlString];

            
            /*
             //這段會跳出alert，通知document準備好了和一個OK按鈕，按了之後跳到
             //- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Preview" message:@"The document is ready!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alert show];
             */
            
            
        });
        
    } else {
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}

#pragma mark - 4 轉換檔案結束
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSession:task:didCompleteWithError:",@"4");
    if (error == nil) {
        NSLog(@"Task: %@ completed successfully", task);
    } else {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
	
    //更新進度條...
    //double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progressView.progress = progress;
            
            //TODO: 不知道為什麼要用reloadData不用beginUpdates
            //但是如果只有部分更新就不要用reloadData全部重畫了
            [self.delegate reloadedFile];
            //            [self.tableView beginUpdates];
            //            [self.tableView endUpdates];
        });
    });
    
    self.downloadTask = nil;
}

// NEWCODE - New method
#pragma mark - 5 點OK以後，顯示檔案
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"alertView:clickedButtonAtIndex:",@"5");
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Ok"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //點完OK後要做的事寫這
        });
    }
    
}

//// NEWCODE - New method
//#pragma mark - 6
//- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
//    NSLog(@"step # %i %@ ----- %@",++stepCount,@"documentInteractionControllerViewControllerForPreview",@"6");
//    return self;
//}

#pragma mark - 應該是這段在訊息送達後觸發appDelegate裡面的通知
/*! 告訴delegate所有序列訊息已經送達*/
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSessionDidFinishEventsForBackgroundURLSession",@"?");
//    nwAppDelegate *appDelegate = (nwAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = self.backgroundSessionCompletionHandler;
        self.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished @URLSessionDidFinishEventsForBackgroundURLSession");
}
//
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:",@"??");
}
/*!確認我的最愛清單是否已經存在，不存在的話複製一份default資料過去
 */
-(void) checkFavoriteList{
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
}

-(void)checkRateFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //手機APP裡的document資料夾（URLs的第0個就是了）
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    destinationURL = [documentsDirectory URLByAppendingPathComponent:@"UIP003.zh-TW.htm"];
    NSString *htmlString=[self readFileIntoString:destinationURL];
    if (htmlString!=nil) {
        [self pickCurrencyAndRateUpFromHtmlString:htmlString];
    }else{
//        [self refresh];
        //TODO: 在appDelegate裡只先處理已經下載的檔案
    }
}
/*!把已經下載下來的destinationURL檔案讀進字串裡
 */
-(NSString *)readFileIntoString:(NSURL *)filePath{
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    return fileContents;
}

/*!從臺銀匯率html字串取得Currency陣列
 */
-(void)pickCurrencyAndRateUpFromHtmlString:(NSString *)htmlString{
//    nwAppDelegate *appDelegate = (nwAppDelegate *)[[UIApplication sharedApplication] delegate];
//    ParseTaiwanBank *twBank=appDelegate.twBank;

    NSString *destinationString=[destinationURL path];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL isExist=[fileManager fileExistsAtPath:destinationString];
    if (isExist) {
        NSDictionary* fileAttribs = [fileManager attributesOfItemAtPath:destinationString error:nil];
        NSDate *creation = fileAttribs [NSFileCreationDate]; //or NSFileModificationDate
        self.twBank.checkDateTime=creation;
    }

    [[self.twBank getExchangeRateFromTaiwanBankRateString:htmlString] allObjects];
    
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
