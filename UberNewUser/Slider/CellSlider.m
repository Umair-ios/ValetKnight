//
//  CellSlider.m
//  UberNewUser
//
//  Created by Elluminati - macbook on 30/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "CellSlider.h"

@implementation CellSlider

#pragma mark -
#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark -
#pragma mark - Methods

-(void)setCellData:(id)data withParent:(id)parent
{
    cellData=data;
    cellParent=parent;
    self.lblName.font = [UberStyleGuide fontSemiBold];
    self.lblName.text=[cellData uppercaseString];
    self.imgIcon.image=[UIImage imageNamed:[NSString stringWithFormat:@"ub__nav_%@",cellData]];
}

@end
