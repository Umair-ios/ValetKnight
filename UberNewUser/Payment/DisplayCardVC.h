//
//  DisplayCardVC.h
//  UberforXOwner
//
//  Created by Deep Gami on 17/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

@interface DisplayCardVC : BaseVC <UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate> {
    
}

- (IBAction)addCardBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
- (IBAction)backBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblNoCards;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoItems;

@end
