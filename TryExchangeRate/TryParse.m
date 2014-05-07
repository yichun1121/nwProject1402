//
//  TryParse.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "TryParse.h"

@implementation TryParse
-(void)tryAppleOfficalSample{
    NSString *string = @"Product: Acme Potato Peeler; Cost: 0.98 73\n\
    Product: Chef Pierre Pasta Fork; Cost: 0.75 19\n\
    Product: Chef Pierre Colander; Cost: 1.27 2\n";
    
    NSCharacterSet *semicolonSet;
    NSScanner *theScanner;
    
    NSString *PRODUCT = @"Product:";
    NSString *COST = @"Cost:";
    
    NSString *productName;
    float productCost;
    NSInteger productSold;
    
    semicolonSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
    theScanner = [NSScanner scannerWithString:string];
    
    while ([theScanner isAtEnd] == NO)
    {
        if ([theScanner scanString:PRODUCT intoString:NULL] &&
            [theScanner scanUpToCharactersFromSet:semicolonSet
                                       intoString:&productName] &&
            [theScanner scanString:@";" intoString:NULL] &&
            [theScanner scanString:COST intoString:NULL] &&
            [theScanner scanFloat:&productCost] &&
            [theScanner scanInteger:&productSold])
        {
            NSLog(@"Sales of %@: $%1.2f", productName, productCost * productSold);
        }
    }

}
@end
