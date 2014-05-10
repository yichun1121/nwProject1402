//
//  RateListTVC.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "RateListTVC.h"
#import "TryParse.h"
#import "NWCustCellExchangeRate.h"
#import "TryLoadURL.h"
#import "nwAppDelegate.h"
#import "currency.h"

@interface RateListTVC ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (retain, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic)  NSMutableSet *currencySet;
@end

static NSString *DownloadURLString =@"http://rate.bot.com.tw/Pages/Static/UIP003.zh-TW.htm";
//static NSString *DownloadURLString =@"https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaTouch64BitGuide/CocoaTouch64BitGuide.pdf";
@implementation RateListTVC{
    // NEWCODE
    NSURL *destinationURL;
}
@synthesize currencySet=_currencySet;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.session = [self backgroundSession];
    
    TryParse *tryParse=[TryParse new];
    [tryParse tryAppleOfficalSample];
    [tryParse tryGetImgURL];
    [tryParse tryTaiwanBankHTML];
    
    //-----註冊CustomCell----------
    UINib* myCellNib = [UINib nibWithNibName:@"NWCustCellExchangeRate" bundle:nil];
    [self.tableView registerNib:myCellNib forCellReuseIdentifier:@"Cell"];
    
}
- (NSURLSession *)backgroundSession {
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}
#pragma mark - 事件
- (IBAction)refreshClicked:(UIBarButtonItem *)sender {
    if (self.downloadTask) {
        return;
    }
    NSURL *downloadURL = [NSURL URLWithString:DownloadURLString];
	NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
	self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    
    //self.progressView.hidden = NO;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (downloadTask == self.downloadTask) {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progressView.progress = progress;
        });
    }
}



- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    // NEWCODE - ivar instead of property
    destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
        
        // NEWCODE
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progressView.hidden = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Preview" message:@"The document is ready!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        });
        
    } else {
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error == nil) {
        NSLog(@"Task: %@ completed successfully", task);
    } else {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
	
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
	dispatch_async(dispatch_get_main_queue(), ^{
		//self.progressView.progress = progress;
	});
    
    self.downloadTask = nil;
}
// NEWCODE - New method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Ok"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *htmlString=[self readFileIntoString:destinationURL];
            [self pickCurrencyAndRateUpFromHtmlString:htmlString];
        });
    }
    
}
/*!把destinationURL檔案讀進字串裡
 */
-(NSString *)readFileIntoString:(NSURL *)filePath{
    NSError *error;
//    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString *fileContents = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    // maybe for debugging...
    NSLog(@"contents: %@", fileContents);
    
    //下面兩句是用換行符號切開成陣列
//    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];
//    NSLog(@"items = %lu", (unsigned long)[listArray count] );
    return fileContents;
}
/*!
 */
-(void)pickCurrencyAndRateUpFromHtmlString:(NSString *)htmlString{
    
    
    Currency *currency=[[Currency alloc]initWithName:@"新臺幣" ISOCode:@"NTD"];
    [self.currencySet addObject:currency];
    
}
// NEWCODE - New method
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller{
    return self;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    nwAppDelegate *appDelegate = (nwAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished");
}

-(NSMutableSet *)currencySet{
    if (!_currencySet) {
        _currencySet=[NSMutableSet new];
    }
    return _currencySet;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier=@"Cell";
    
    NWCustCellExchangeRate *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[NWCustCellExchangeRate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell=[self configureCell:cell AtIndexPath:indexPath];
    
    return cell;
}
-(NWCustCellExchangeRate *)configureCell:(NWCustCellExchangeRate *)cell AtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==0) {
        UIFont *descriptionFont=[UIFont fontWithName:cell.currencyCode.font.fontName size:13];
        for (UILabel *label in cell.contentView.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                label.font=descriptionFont;
            }
        }
        cell.currencyCode.text=@"";
        cell.currencyName.text=@"幣別";
        cell.spotSellingPrice.text=@"即期賣出";
        cell.spotBuyingPrice.text=@"即期買入";
        cell.cashSellingPrice.text=@"現金賣出";
        cell.cashBuyingPrice.text=@"現金買入";
        cell.backgroundColor=[UIColor colorWithRed:0.95 green:0.9 blue:0.9 alpha:0.8];
    }else{
        cell.imageView.image=[UIImage imageNamed:@"CHF"];
    }
    return cell;
}
@end
