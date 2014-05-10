//
//  TryLoadURL.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/8.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "TryLoadURL.h"

@interface TryLoadURL ()
@end
NSString *londonWeatherUrl =
@"http://rate.bot.com.tw/Pages/Static/UIP003.zh-TW.htm";
//@"http://api.openweathermap.org/data/2.5/weather?q=London,uk";

@implementation TryLoadURL

-(void)call{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:londonWeatherUrl]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // handle response
                
            }] resume];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"download");
}
@end
