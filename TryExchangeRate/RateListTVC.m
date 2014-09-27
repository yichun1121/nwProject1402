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

@property (nonatomic, strong) UIRefreshControl *refreshControl;
//@property (nonatomic, strong) IBOutlet UITableView * refreshView;    //(你要下拉更新的TableView)
@property (nonatomic) ParseTaiwanBank *appTWBank;
@property (nonatomic) nwAppDelegate *appDelegate;

@end
@implementation RateListTVC{
    // NEWCODE
    NSURL *destinationURL;
    int stepCount;

}
@synthesize currencyArray=_currencyArray;
@synthesize appTWBank=_appTWBank;
@synthesize appDelegate=_appDelegate;
-(nwAppDelegate *)appDelegate{
    if(!_appDelegate){
        _appDelegate= (nwAppDelegate *)[[UIApplication sharedApplication] delegate];
        _appDelegate.delegate=self;
    }
    return _appDelegate;
}
-(ParseTaiwanBank *)appTWBank{
    if (!_appTWBank) {
        _appTWBank=self.appDelegate.twBank;
    }
    return _appTWBank;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.progressView.progress = 0;
//    self.progressView.hidden = YES;
    
    //-----註冊CustomCell----------
    UINib* myCellNib = [UINib nibWithNibName:@"NWCustCellExchangeRate" bundle:nil];
    [self.tableView registerNib:myCellNib forCellReuseIdentifier:@"Cell"];
    //-----設定refresh controller---------
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
//    [self.refreshView addSubview:self.refreshControl]; //把RefreshControl加到TableView中

    
}
-(void)viewWillAppear:(BOOL)animated{
    //-----檢查有沒有之前下載的檔----------
    if (self.currencyArray.count==0) {
        [self refresh];
    }else{
        [self reloadTableView];
    }
}
- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender {
    [self refresh];
}

#pragma mark - 1 refresh事件
/*!下拉更新之後要做的事
 */
-(void) refresh{
    NSLog(@"step # %i %@ ----- %@",++stepCount,@"start",@"1");
	if (self.appDelegate.downloadTask) {
        return;
    }
    //把網址字串轉成URL
    NSURL *downloadURL = [NSURL URLWithString:self.appTWBank.downloadURLString];
    //設定URL request
	NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    //發出request
	self.appDelegate.downloadTask = [self.appDelegate.session downloadTaskWithRequest:request];
    [self.appDelegate.downloadTask resume];
    //self.progressView.hidden = NO;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)currencyArray{
//    if (!_currencyArray) {
//        _currencyArray=self.appTWBank.currencyArray;
//    }
//    return _currencyArray;
    return self.appTWBank.currencyArray;
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
        
        self.navigationItem.title=[NSString stringWithFormat:@"檢查時間: %@",[self.appDelegate.dateFormatter stringFromDate:self.appTWBank.checkDateTime ]];
        
        cell.backgroundColor=[UIColor colorWithRed:0.95 green:0.9 blue:0.9 alpha:0.8];
        UIFont *descriptionFont=[UIFont fontWithName:cell.currencyCode.font.fontName size:13];
        for (UILabel *label in cell.contentView.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                label.font=descriptionFont;
            }
        }
        cell.currencyCode.text=self.appTWBank.updateDayTimeString;
        cell.currencyName.text=@"幣別";
        cell.spotSellingPrice.text=@"即期賣出";
        cell.spotBuyingPrice.text=@"即期買入";
        cell.cashSellingPrice.text=@"現金賣出";
        cell.cashBuyingPrice.text=@"現金買入";
        cell.imageView.image=nil;
        //----- button image -----
        cell.favorite.imageView.image=nil;
        cell.favorite.enabled=NO;
        //----- button action -----
        NSArray *btnActions= [cell.favorite actionsForTarget:nil forControlEvent:UIControlEventTouchUpInside];
        if (btnActions) {
            [cell.favorite removeTarget:self action:@selector(clickFavorite:) forControlEvents:UIControlEventTouchUpInside];
        }
    }else{
        //----- cell color ------
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
        //----- info -----
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
            //----- button image -----
            if (currency.isFavorite) {
                cell.favorite.selected=YES;
                cell.favorite.enabled=YES;
            }else{
                cell.favorite.selected=NO;
                cell.favorite.enabled=YES;
            }
            //----- button action -----
            NSArray *btnActions= [cell.favorite actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];

            if (!btnActions) {
                [cell.favorite addTarget:self action:@selector(clickFavorite:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
    }
    return cell;
}
- (IBAction)clickFavorite:(UIButton *)sender{
    UITableViewCell *cell=(UITableViewCell *)sender.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Currency *currency=[self.currencyArray objectAtIndex:indexPath.row-1];
    currency.isFavorite=!currency.isFavorite;
    nwAppDelegate *appDelegate = (nwAppDelegate *)[[UIApplication sharedApplication] delegate];
    ParseTaiwanBank *twBank=appDelegate.twBank;
    if (currency.isFavorite) {
        [twBank addFavorite:currency.codeISO];
    }else{
        [twBank removeFavorite:currency.codeISO];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)reloadedFile{
    [self.tableView reloadData];
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    
}
-(void) reloadTableView{
    [self.tableView reloadData];
}
@end
