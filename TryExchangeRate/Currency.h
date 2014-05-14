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
@property NSString *spotBuyingRate;
@property NSString *spotSellingRate;
@property NSString *cashBuyingRate;
@property NSString *cashSellingRate;
@property BOOL isFavorite;

-(id)initWithName:(NSString *)currencyName ISOCode:(NSString *)currencyISOCode;

@end

