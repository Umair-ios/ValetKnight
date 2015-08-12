//
//  CarTypeCell.h
//  UberforXOwner
//
//  Created by Deep Gami on 14/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarTypeDataModal;
@interface CarTypeCell : UICollectionViewCell
{
    CarTypeDataModal *cellData;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgType;
@property (weak, nonatomic) IBOutlet UIButton *btnType;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgCheck;

- (void)setCellData:(CarTypeDataModal *)data;

@end
