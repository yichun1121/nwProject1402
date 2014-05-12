//
//  ParseTaiwanBank.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/11.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "ParseTaiwanBank.h"
#import "Currency.h"
@interface ParseTaiwanBank()
@end
@implementation ParseTaiwanBank
@synthesize currencyArray=_currencyArray;
@synthesize updateDayTimeString=_updateDayTimeString;
-(NSMutableOrderedSet *)getExchangeRateFromTaiwanBankRateString:(NSString *)htmlString{
    NSMutableOrderedSet *currencySet=[NSMutableOrderedSet new];
    
    NSString *updateTime;
    NSString *currencyName;
    NSString *currencyCode;
    NSString *cashBuying;
    NSString *cashSelling;
    NSString *spotBuying;
    NSString *spotSelling;
    
    NSScanner *theScanner = [NSScanner scannerWithString:htmlString];
    
    NSString *tagBeforeUpdateTime=@"牌價最新掛牌時間：&nbsp;";
    NSString *tagAfterUpdateTime=@"</td>";
    NSString *tagTableFront=@"<table title=\"牌告匯率\"";
    NSString *tagBeforeName=@".gif\" title=\"\" alt=\"\" />&nbsp;";
    NSString *tagAfterNameBeforeCode=@" (";
    NSCharacterSet *bracketRightSet = [NSCharacterSet characterSetWithCharactersInString:@")"];
    NSString *tagBeforeDecimal=@"<td class=\"decimal\">";
    NSString *tagAfterDecimal=@"</td>";
    NSString *tagTableAfter=@"</table>";
    
    NSInteger tagLocationTableFront=0;
    NSInteger tagLocationTableAfter=0;

    
    while (![theScanner isAtEnd]) {
        //-----確認匯率更新時間-----
        [theScanner scanUpToString:tagBeforeUpdateTime intoString:nil];
        //NSLog(@"scan location:before time %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeUpdateTime.length];
        [theScanner scanUpToString:tagAfterUpdateTime intoString:&updateTime];
        NSLog(@"======= %@======= %lu",updateTime,(unsigned long)[theScanner scanLocation] );
        self.updateDayTimeString=updateTime;
        
        //-----確認牌告匯率table範圍-----
        NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner scanUpToString:tagTableFront intoString:nil];
        tagLocationTableFront=[theScanner scanLocation];    //記錄table起始位置
        NSLog(@"scan location:table start %lu",(unsigned long)[theScanner scanLocation] );
        [theScanner scanUpToString:tagTableAfter intoString:nil];
        tagLocationTableAfter=[theScanner scanLocation];    //記錄table結束位置（以便判斷找完沒）
        NSLog(@"scan location:table end %lu",(unsigned long)[theScanner scanLocation] );
        //回到起始位置準備開始掃描
        theScanner.scanLocation=tagLocationTableFront;
        NSLog(@"scan location: %lu",(unsigned long)[theScanner scanLocation] );
    
        //TODO:不知為什麼，全部幣別都抓完後再抓tagBeforeName仍然會有資料，所以只好檢查scanLocation，超出table範圍就跳出
        while ([theScanner scanUpToString:tagBeforeName intoString:nil]&&theScanner.scanLocation<tagLocationTableAfter) {
            //-----幣別中文-----
            [theScanner scanUpToString:tagBeforeName intoString:nil];
            //NSLog(@"scan location:before name %lu",(unsigned long)[theScanner scanLocation] );
            [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeName.length];
            [theScanner scanUpToString:tagAfterNameBeforeCode intoString:&currencyName];
            NSLog(@"scan location:%@ %lu",currencyName,(unsigned long)[theScanner scanLocation] );
            //-----幣別代碼-----
            [theScanner setScanLocation: [theScanner scanLocation]+tagAfterNameBeforeCode.length];
            [theScanner scanUpToCharactersFromSet:bracketRightSet intoString:&currencyCode];
            NSLog(@"scan location:(%@) %lu",currencyCode,(unsigned long)[theScanner scanLocation] );
            
            //-----匯率-----
            int indexRate=0;
            while(indexRate<4) {
                NSString *rateString;
                @try {
                    [theScanner scanUpToString:tagBeforeDecimal intoString:nil];
                    [theScanner setScanLocation: [theScanner scanLocation]+tagBeforeDecimal.length];
                    [theScanner scanUpToString:tagAfterDecimal intoString:&rateString];
                    //NSLog(@"scan location:%@ %lu",rateString,(unsigned long)[theScanner scanLocation] );
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
            Currency *currency=[[Currency alloc]initWithName:currencyName ISOCode:currencyCode];
            currency.cashBuyingRate=[self fitSizeRate:cashBuying];
            currency.cashSellingRate=[self fitSizeRate:cashSelling];
            currency.spotBuyingRate=[self fitSizeRate:spotBuying];
            currency.spotSellingRate=[self fitSizeRate:spotSelling];
            [currencySet addObject:currency];
        }
        if (theScanner.scanLocation>tagLocationTableAfter) {
            //超出牌告匯率table範圍，上面的while就不會作用，可以直接break跳出
            break;
        }
        
    }
    NSLog(@"-----共%lu筆資訊-----",(unsigned long)currencySet.count);
    self.currencyArray=[[currencySet copy]allObjects];
    return currencySet;
}
-(NSString *)fitSizeRate:(NSString *)rate{
    NSString *fitRat;
    if ([rate rangeOfString:@"0.0"].location != NSNotFound){
        fitRat=rate;    //0.0xxx 五位小數  ex:韓元,印尼
    }else if ([rate rangeOfString:@"0."].location != NSNotFound){
        fitRat=[rate substringToIndex:rate.length-1];   //0.xxx 四位小數  ex:日元
    }else if ([rate rangeOfString:@"."].location != NSNotFound){
        fitRat=[rate substringToIndex:rate.length-2];   //大於1 三位小數  ex:美金
    }else{
        fitRat=rate;    //沒有數字  ex:南非幣沒有現金匯率
    }
    return fitRat;
}
@end
