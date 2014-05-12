//
//  RateListTVC.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "RateListTVC.h"
//#import "TryParse.h"
#import "NWCustCellExchangeRate.h"
//#import "TryLoadURL.h"
#import "nwAppDelegate.h"
#import "Currency.h"
#import "ParseTaiwanBank.h"

@interface RateListTVC ()

@property (weak, nonatomic) IBOutlet UILabel *updateDayTime;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (retain, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic)  NSArray *currencyArray;
@end
static NSString *DownloadURLString =@"http://rate.bot.com.tw/Pages/Static/UIP003.zh-TW.htm";
@implementation RateListTVC{
    // NEWCODE
    NSURL *destinationURL;
    int stepCount;

}
@synthesize currencyArray=_currencyArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.session = [self backgroundSession];
//    self.progressView.progress = 0;
//    self.progressView.hidden = YES;
    
    //-----註冊CustomCell----------
    UINib* myCellNib = [UINib nibWithNibName:@"NWCustCellExchangeRate" bundle:nil];
    [self.tableView registerNib:myCellNib forCellReuseIdentifier:@"Cell"];
    //-----檢查有沒有之前下載的檔----------
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //手機APP裡的document資料夾（URLs的第0個就是了）
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    destinationURL = [documentsDirectory URLByAppendingPathComponent:@"UIP003.zh-TW.htm"];
    NSString *htmlString=[self readFileIntoString:destinationURL];
    
    [self pickCurrencyAndRateUpFromHtmlString:htmlString];
    
}
/*! 設定NSURLSession.delegate=self（在viewDidLoad的時候就設好session了）
 */
- (NSURLSession *)backgroundSession {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"backgroundSession",@"pre 2");
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}
#pragma mark - 1 refresh事件
- (IBAction)refreshClicked:(UIBarButtonItem *)sender {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"start",@"1");
	if (self.downloadTask) {
        return;
    }
    //把網址字串轉成URL
    NSURL *downloadURL = [NSURL URLWithString:DownloadURLString];
    //設定URL request
	NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    //發出request
	self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    
    //self.progressView.hidden = NO;
}
#pragma mark - 2 應該是check progress bar的過程
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite",@"2");
    if (downloadTask == self.downloadTask) {
        //更新進度條...
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progressView.progress = progress;
        });
        NSLog(@"step # %i %@ ----- %@",++stepCount,@"downloadTask == self.downloadTask",@"2");
    }
}


#pragma mark - 3 下載過程結束。（檔案copy成功時會跳出The document is ready!!）
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSession:downloadTask:didFinishDownloadingToURL:",@"3");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //手機APP裡的document資料夾（URLs的第0個就是了）
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    //原始完整網址
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    // NEWCODE - ivar instead of property
    //拷貝後完整網址（資料夾+原始網址最後的檔名）
    destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
        
        // NEWCODE
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.progressView.hidden = YES;

            //download完後開始處理字串
            NSString *htmlString=[self readFileIntoString:destinationURL];
            [self pickCurrencyAndRateUpFromHtmlString:htmlString];
            //TODO: 不知道為什麼要用reloadData不用beginUpdates
            //但是如果只有部分更新就不要用reloadData全部重畫了
            [self.tableView reloadData];
//            [self.tableView beginUpdates];
//            [self.tableView endUpdates];
            
            /*
             //這段會跳出alert，通知document準備好了和一個OK按鈕，按了之後跳到
             //- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Preview" message:@"The document is ready!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
             */
            
            
        });
        
    } else {
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}

#pragma mark - 4 轉換檔案結束
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSession:task:didCompleteWithError:",@"4");
    if (error == nil) {
        NSLog(@"Task: %@ completed successfully", task);
    } else {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
	
    //更新進度條...
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
	dispatch_async(dispatch_get_main_queue(), ^{
		//self.progressView.progress = progress;
	});
    
    self.downloadTask = nil;
}


// NEWCODE - New method
#pragma mark - 5 點OK以後，顯示檔案
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"alertView:clickedButtonAtIndex:",@"5");
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Ok"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //點完OK後要做的事寫這
        });
    }
    
}
/*!把已經下載下來的destinationURL檔案讀進字串裡
 */
-(NSString *)readFileIntoString:(NSURL *)filePath{
    NSError *error;
//    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString *fileContents = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    // maybe for debugging...
    //NSLog(@"contents: %@", fileContents);
    
    //下面兩句是用換行符號切開成陣列
//    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];
//    NSLog(@"items = %lu", (unsigned long)[listArray count] );
    return fileContents;
}

/*!從臺銀匯率html字串取得Currency陣列
 */
-(void)pickCurrencyAndRateUpFromHtmlString:(NSString *)htmlString{
    ParseTaiwanBank *twBank=[ParseTaiwanBank new];
    self.currencyArray=[[twBank getExchangeRateFromTaiwanBankRateString:htmlString] allObjects];
    self.updateDayTime.text=twBank.updateDayTimeString;
    
}
// NEWCODE - New method
#pragma mark - 6
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"documentInteractionControllerViewControllerForPreview",@"6");
    return self;
}

#pragma mark - 應該是這段在訊息送達後觸發appDelegate裡面的通知
/*! 告訴delegate所有序列訊息已經送達*/
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSessionDidFinishEventsForBackgroundURLSession",@"?");
    nwAppDelegate *appDelegate = (nwAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished @URLSessionDidFinishEventsForBackgroundURLSession");
}
//
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:",@"??");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)currencyArray{
    if (!_currencyArray) {
        _currencyArray=[NSArray new];
    }
    return _currencyArray;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currencyArray.count+1;
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
        cell.backgroundColor=[UIColor colorWithRed:0.95 green:0.9 blue:0.9 alpha:0.8];
        UIFont *descriptionFont=[UIFont fontWithName:cell.currencyCode.font.fontName size:13];
        for (UILabel *label in cell.contentView.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                label.font=descriptionFont;
            }
        }
        cell.currencyCode.text=self.updateDayTime.text;
        cell.currencyName.text=@"幣別";
        cell.spotSellingPrice.text=@"即期賣出";
        cell.spotBuyingPrice.text=@"即期買入";
        cell.cashSellingPrice.text=@"現金賣出";
        cell.cashBuyingPrice.text=@"現金買入";
        cell.imageView.image=nil;
    }else{
        if (cell.backgroundColor!=[UIColor clearColor]) {
            cell.backgroundColor=[UIColor clearColor];
            UIFont *rateFont=[UIFont fontWithName:cell.currencyCode.font.fontName size:16];
            UIFont *nameFont=[UIFont fontWithName:cell.currencyCode.font.fontName size:13];
            for (UILabel *label in cell.contentView.subviews) {
                if ([label isKindOfClass:[UILabel class]]) {
                    label.font=rateFont;
                }
            }
            cell.currencyName.font=nameFont;
        }
        long index=indexPath.row-1;
        if (index<self.currencyArray.count) {
            Currency *currency=self.currencyArray[indexPath.row-1];
            cell.imageView.image=[UIImage imageNamed:currency.codeISO];
            cell.currencyName.text=currency.name;
            cell.currencyCode.text=currency.codeISO;
            cell.cashBuyingPrice.text=currency.cashBuyingRate;
            cell.cashSellingPrice.text=currency.cashSellingRate;
            cell.spotBuyingPrice.text=currency.spotBuyingRate;
            cell.spotSellingPrice.text=currency.spotSellingRate;
        }
        
    }
    return cell;
}
@end
