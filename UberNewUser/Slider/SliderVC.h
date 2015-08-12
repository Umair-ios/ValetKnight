//
//  SliderVC.h
//  Employee
//
//  Created by Elluminati - macbook on 19/05/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "BaseVC.h"
#import "PickUpVC.h"

@interface SliderVC : BaseVC<UITableViewDataSource,UITableViewDelegate>
{
    UIViewController *frontVC;
    NSMutableArray *arrSlider,*arrImages;
    
}
@property(weak,nonatomic)IBOutlet UITableView *tblMenu;
@property (nonatomic,strong) PickUpVC *ViewObj;
@property (nonatomic, weak) IBOutlet UIImageView *imgProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end
