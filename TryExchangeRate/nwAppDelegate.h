//
//  nwAppDelegate.h
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseTaiwanBank.h"
@interface nwAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic)  ParseTaiwanBank *twBank;
@property (copy) void (^backgroundSessionCompletionHandler)();

@end
