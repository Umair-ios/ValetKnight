//
//  CellSlider.h
//  UberNewUser
//
//  Created by Elluminati - macbook on 30/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellSlider : UITableViewCell
{
    id cellData;
    id cellParent;
}
@property(nonatomic,weak)IBOutlet UIImageView *imgIcon;
@property(nonatomic,weak)IBOutlet UILabel *lblName;

-(void)setCellData:(id)data withParent:(id)parent;

@end
