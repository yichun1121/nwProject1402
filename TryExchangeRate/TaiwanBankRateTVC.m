//
//  TaiwanBankRateTVC.m
//  TryExchangeRate
//
//  Created by YICHUN on 2014/5/14.
//  Copyright (c) 2014年 nw. All rights reserved.
//

#import "TaiwanBankRateTVC.h"

@interface TaiwanBankRateTVC ()
@property (nonatomic, strong) IBOutlet UITableView * refreshView;    //(你要下拉更新的TableView)

@end

@implementation TaiwanBankRateTVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
