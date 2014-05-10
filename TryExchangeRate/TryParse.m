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

}-(void)tryTaiwanBankHTML{
    
    NSString *exampleString =@"<table title=\"牌告匯率\"><tr class=\"color0\"><td class=\"titleLeft\"><img class=\"paddingLeft16\" src=\"/Images/Flags/America.gif\" title=\"\" alt=\"\" />&nbsp;美金 (USD)</td><td class=\"decimal\">29.75500</td><td class=\"decimal\">30.29700</td><td class=\"decimal\">30.05500</td><td class=\"decimal\">30.15500</td><td class=\"link\" colspan=\"1\"><a href=\"/Pages/UIP003/UIP0031.aspx?lang=zh-TW&static=open&whom=USD&date=2014-05-07T16:02:31&type=L\">查詢</a></td><td class=\"link\" colspan=\"1\"><a target='_blank'href=\"/Pages/UIP004/UIP004INQ1.aspx?lang=zh-TW&whom3=USD\">查詢</a></td></tr></table>";
    
    NSString *currencyName;
    NSString *currencyCode;
    NSString *cashBuying;
    NSString *cashSelling;
    NSString *spotBuying;
    NSString *spotSelling;

    NSString *htmlString = exampleString;
    NSScanner *theScanner = [NSScanner scannerWithString:htmlString];

    NSString *tagTable=@"<table title=\"牌告匯率\">";
    NSString *tagBeforeName=@".gif\" title=\"\" alt=\"\" />&nbsp;";
    NSString *tagAfterNameBeforeCode=@" (";
    NSCharacterSet *bracketRightSet = [NSCharacterSet characterSetWithCharactersInString:@")"];
    NSString *tagBeforeDecimal=@"<td class=\"decimal\">";
    NSString *tagAfterDecimal=@"</td>";
    

    NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
    [theScanner scanUpToString:tagTable intoString:nil];
    NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
    if (![theScanner isAtEnd]) {
        //-----幣別中文-----
        [theScanner scanUpToString:tagBeforeName intoString:nil];
        NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeName.length];
        [theScanner scanUpToString:tagAfterNameBeforeCode intoString:&currencyName];
        NSLog(@"scan location:%@ %lu",currencyName,(unsigned long)[theScanner scanLocation] );
        //-----幣別代碼-----
        [theScanner setScanLocation: [theScanner scanLocation]+tagAfterNameBeforeCode.length];
        [theScanner scanUpToCharactersFromSet:bracketRightSet intoString:&currencyCode];
        NSLog(@"scan location:%@ %lu",currencyCode,(unsigned long)[theScanner scanLocation] );
        
        //-----匯率-----
/*
        NSLog(@"匯率");
        //decimal
        [theScanner scanUpToString:tagBeforeDecimal intoString:nil];
        NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeDecimal.length];
        NSLog(@"scan location:+ %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner scanUpToString:tagAfterDecimal intoString:&cashBuying];
        NSLog(@"scan location:%@ %lu",cashBuying,(unsigned long)[theScanner scanLocation] );
        //decimal
        [theScanner scanUpToString:tagBeforeDecimal intoString:nil];
        NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeDecimal.length];
        NSLog(@"scan location:+ %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner scanUpToString:tagAfterDecimal intoString:&cashSelling];
        NSLog(@"scan location:%@ %lu",cashSelling,(unsigned long)[theScanner scanLocation] );
        //decimal
        [theScanner scanUpToString:tagBeforeDecimal intoString:nil];
        NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeDecimal.length];
        NSLog(@"scan location:+ %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner scanUpToString:tagAfterDecimal intoString:&spotBuying];
        NSLog(@"scan location:%@ %lu",spotBuying,(unsigned long)[theScanner scanLocation] );
        //decimal
        [theScanner scanUpToString:tagBeforeDecimal intoString:nil];
        NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeDecimal.length];
        NSLog(@"scan location:+ %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner scanUpToString:tagAfterDecimal intoString:&spotSelling];
        NSLog(@"scan location:%@ %lu",spotSelling,(unsigned long)[theScanner scanLocation] );
*/
        
        
        int indexRate=0;
        while(indexRate<4) {
            NSString *rateString;
            @try {
                [theScanner scanUpToString:tagBeforeDecimal intoString:nil];
                [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeDecimal.length];
                [theScanner scanUpToString:tagAfterDecimal intoString:&rateString];
                NSLog(@"scan location:%@ %lu",rateString,(unsigned long)[theScanner scanLocation] );
                switch (indexRate) {
                    case 0:
                        cashBuying=rateString;
                        break;
                    case 1:
                        cashSelling=rateString;
                        break;
                    case 2:
                        spotBuying=rateString;
                        break;
                    case 3:
                        spotSelling=rateString;
                        break;
                }
                indexRate++;
            }
            @catch (NSException *exception) {
                NSLog(@"NSScanner error when getting rate at index=%i.",indexRate);
                break;  //有問題就跳出回圈
            }
        }
        if(indexRate!=4){
            //代表四個匯率中有一個以上有問題
            NSString *errorRate=@"x";
            cashBuying=errorRate;
            cashSelling=errorRate;
            spotBuying=errorRate;
            spotSelling=errorRate;
        }
    }
    NSLog(@"-----%@, %@-----cashSelling:%@",currencyName,currencyCode,cashSelling);
}

-(void)tryTaiwanBankHTMLIntoDouble{
    
    NSString *exampleString =@"<table title=\"牌告匯率\"><tr class=\"color0\"><td class=\"titleLeft\"><img class=\"paddingLeft16\" src=\"/Images/Flags/America.gif\" title=\"\" alt=\"\" />&nbsp;美金 (USD)</td><td class=\"decimal\">29.75500</td><td class=\"decimal\">30.29700</td><td class=\"decimal\">30.05500</td><tdclass=\"decimal\">30.15500</td><td class=\"link\" colspan=\"1\"><a href=\"/Pages/UIP003/UIP0031.aspx?lang=zh-TW&static=open&whom=USD&date=2014-05-07T16:02:31&type=L\">查詢</a></td><td class=\"link\" colspan=\"1\"><a target='_blank'href=\"/Pages/UIP004/UIP004INQ1.aspx?lang=zh-TW&whom3=USD\">查詢</a></td></tr></table>";
//    NSString *exampleString =@"America.gif\" title=\"\" alt=\"\" />&nbsp;美金 (USD)</td><td class=\"decimal\">29.75500</td><td class=\"decimal\">30.29700</td><td class=\"decimal\">30.05500</td><tdclass=\"decimal\">30.15500</td><td class=\"link\" colspan=\"1\"><a href=\"/Pages/UIP003/UIP0031.aspx?lang=zh-TW&static=open&whom=USD&date=2014-05-07T16:02:31&type=L\">查詢</a></td><td class=\"link\" colspan=\"1\"><a target='_blank'href=\"/Pages/UIP004/UIP004INQ1.aspx?lang=zh-TW&whom3=USD\">查詢</a></td></tr></table>";

    NSString *currencyName;
    NSString *currencyCode;
    double d;
    NSString *htmlString = exampleString;
    NSScanner *theScanner = [NSScanner scannerWithString:htmlString];
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"\"';"];
    //NSCharacterSet *biggerSmallerSet = [NSCharacterSet characterSetWithCharactersInString:@"><"];
    // find start of IMG tag
    NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );         //0
    [theScanner scanUpToString:@".gif\" title=\"\" alt=\"\" />" intoString:nil];
    NSLog(@"scan location:. %lu",(unsigned long)[theScanner scanLocation] );         //7
    if (![theScanner isAtEnd]) {
        [theScanner scanUpToString:@"&nbsp;" intoString:nil];
        NSLog(@"scan location:& %lu",(unsigned long)[theScanner scanLocation] );     //31
        [theScanner scanUpToCharactersFromSet:charset intoString:nil];
        NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );     //36
        [theScanner setScanLocation: [theScanner scanLocation]+1];
        NSLog(@"scan location:+1 %lu",(unsigned long)[theScanner scanLocation] );     //37
        [theScanner scanUpToString:@" (" intoString:&currencyName];
        NSLog(@"scan location:%@ %lu",currencyName,(unsigned long)[theScanner scanLocation] );     //39
        [theScanner setScanLocation: [theScanner scanLocation]+2];
        NSLog(@"scan location:+2 %lu",(unsigned long)[theScanner scanLocation] );     //41
        [theScanner scanUpToString:@")" intoString:&currencyCode];
        NSLog(@"scan location:%@ %lu",currencyCode,(unsigned long)[theScanner scanLocation] );     //44

        
        // set it to skip non-numeric characters
        [theScanner setCharactersToBeSkipped:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        while([theScanner scanDouble:&d]){
            NSLog(@"scan location: %1.4f %lu",d,(unsigned long)[theScanner scanLocation]);  //78,111,144,176
        }
        

        // "url" now contains the URL of the img
    }
    NSLog(@"-----%@, %@-----",currencyName,currencyCode);
    
    
}
-(void)tryGetImgURL{
    NSString *exampleString =@"	<a href=\"http://www.mobile.safilsunny.com\"><img src=\"http://www.mobile.safilsunny.com/wp-content/themes/Polished/images/logo.png\" alt=\"Logo\" id=\"logo\"/></a>";
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *targetString;
    NSString *htmlString = exampleString;
    NSScanner *theScanner = [NSScanner scannerWithString:htmlString];
    // find start of IMG tag
    [theScanner scanUpToString:@"<img " intoString:nil];
    if (![theScanner isAtEnd]) {
        [theScanner scanUpToString:@"src" intoString:nil];
        NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
        [theScanner scanUpToCharactersFromSet:charset intoString:nil];
        [theScanner scanCharactersFromSet:charset intoString:nil];
        [theScanner scanUpToCharactersFromSet:charset intoString:&targetString];
        // "url" now contains the URL of the img
    }
    if (targetString.length==0) {
        targetString= @"no Image Tag";
    }
    NSLog(@"target:%@",targetString);
}

@end
