//
//  SupportVC.h
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"

@interface HistoryVC : BaseVC<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewForBill;
- (IBAction)closeBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

@property (weak, nonatomic) IBOutlet UILabel *lblnoHistory;
//////////// Outlets Price Label


@property (weak, nonatomic) IBOutlet UILabel *lblBasePrice;
@property (weak, nonatomic) IBOutlet UILabel *lblDistCost;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeCost;
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblPerDist;
@property (weak, nonatomic) IBOutlet UILabel *lblPerTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoDisplay;
@property (weak, nonatomic) IBOutlet UILabel *totalAmtLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalSavedLbl;

////////////


@end
