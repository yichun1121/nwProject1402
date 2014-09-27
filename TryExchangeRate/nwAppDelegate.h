//
//  nwAppDelegate.h
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseTaiwanBank.h"
@class nwAppDelegate;
@protocol nwAppDelegateDelegate <NSObject>
-(void)reloadedFile;
@end

@interface nwAppDelegate : UIResponder <UIApplicationDelegate,NSURLSessionDataDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic)  ParseTaiwanBank *twBank;
@property (copy) void (^backgroundSessionCompletionHandler)();


@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (retain, nonatomic) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (weak,nonatomic) id<nwAppDelegateDelegate> delegate;
@end
