//
//  Currency.h
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/9.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Currency : NSObject
@property NSString *name;
@property NSString *codeISO;
@property NSDecimal *spotBuyingRate;
@property NSDecimal *spotSellingRate;
@property NSDecimal *cashBuyingRate;
@property NSDecimal *cashSellingRate;

-(id)initWithName:(NSString *)currencyName ISOCode:(NSString *)currencyISOCode;

@end

