//
//  CarTypeCell.m
//  UberforXOwner
//
//  Created by Deep Gami on 14/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "CarTypeCell.h"
#import "CarTypeDataModal.h"
#import "UIImageView+Download.h"

@implementation CarTypeCell

- (void)setCellData:(CarTypeDataModal *)data {
    cellData = data;
    if (cellData.icon==nil || [cellData.icon isKindOfClass:[NSNull class]]){
        self.imgType.image=[UIImage imageNamed:@"button_limo.png"];
    }
    else{
        if ([cellData.icon isEqualToString:@""]) {
            self.imgType.image=[UIImage imageNamed:@"button_limo.png"];
        }
        else{
            [self.imgType downloadFromURL:cellData.icon withPlaceholder:nil];
        }
    }
    self.lblTitle.text=cellData.name;
    if(cellData.isSelected)
        self.imgCheck.hidden=NO;
    else
        self.imgCheck.hidden=YES;
}

@end
