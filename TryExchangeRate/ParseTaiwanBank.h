//
//  ParseTaiwanBank.h
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/11.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseTaiwanBank : NSObject
-(NSSet *)getExchangeRateFromTaiwanBankRateString:(NSString *)htmlString;
@property NSArray * currencyArray;
@property NSString *updateDayTimeString;
@end
