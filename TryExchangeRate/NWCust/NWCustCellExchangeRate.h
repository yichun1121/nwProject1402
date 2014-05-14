//
//  NWCustCellExchangeRate.h
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/7.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NWCustCellExchangeRate : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *currencyCode;
@property (weak, nonatomic) IBOutlet UILabel *currencyName;
@property (weak, nonatomic) IBOutlet UILabel *cashBuyingPrice;
@property (weak, nonatomic) IBOutlet UILabel *cashSellingPrice;
@property (weak, nonatomic) IBOutlet UILabel *spotBuyingPrice;
@property (weak, nonatomic) IBOutlet UILabel *spotSellingPrice;
@property (weak, nonatomic) IBOutlet UIButton *favorite;
- (IBAction)clickFavorite:(UIButton *)sender;

@end
