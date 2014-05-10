//
//  Currency.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/9.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "Currency.h"

@implementation Currency : NSObject
@synthesize name,codeISO,spotBuyingRate,spotSellingRate,cashBuyingRate,cashSellingRate;

-(id)initWithName:(NSString *)currencyName ISOCode:(NSString *)currencyISOCode{
    self.name=currencyName;
    self.codeISO=currencyISOCode;
    return self;
}
@end
