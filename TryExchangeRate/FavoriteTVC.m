//
//  FavoriteTVC.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/14.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "FavoriteTVC.h"
#import "Currency.h"

@interface FavoriteTVC ()
//@property (nonatomic, strong) IBOutlet UITableView * refreshView;    //(你要下拉更新的TableView)
@end

@implementation FavoriteTVC

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
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(NWCustCellExchangeRate *)configureCell:(NWCustCellExchangeRate *)cell AtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        cell=[super configureCell:cell AtIndexPath:indexPath];
        cell.hidden=NO;
    }else{
        long index=indexPath.row-1;
        Currency *currency=[super.currencyArray objectAtIndex:index];
        if (currency.isFavorite) {
            cell=[super configureCell:cell AtIndexPath:indexPath];
            cell.hidden=NO;
        }else{
            cell.hidden=YES;
        }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float height=44;
    if (indexPath.row==0) {
    }else{
        long index=indexPath.row-1;
        Currency *currency=[super.currencyArray objectAtIndex:index];
        if (currency.isFavorite) {

        }else{
            height= 0;
        }
    }
    return height;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
