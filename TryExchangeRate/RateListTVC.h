//
//  RateListTVC.h
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nwAppDelegate.h"
#import "NWCustCellExchangeRate.h"

@interface RateListTVC : UITableViewController<NSURLSessionDelegate,UIDocumentInteractionControllerDelegate,nwAppDelegateDelegate>
-(NWCustCellExchangeRate *)configureCell:(NWCustCellExchangeRate *)cell AtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic)  NSArray *currencyArray;
-(void) reloadTableView;
@end
