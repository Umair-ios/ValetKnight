//
//  CarTypeDataModal.h
//  UberforXOwner
//
//  Created by Deep Gami on 14/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarTypeDataModal : NSObject
@property (nonatomic,strong) NSString *id_;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *is_default;
@property (nonatomic,strong) NSString *price_per_unit_time;
@property (nonatomic,strong) NSString *price_per_unit_distance;
@property (nonatomic,strong) NSString *base_price;
@property (nonatomic,assign)BOOL isSelected;
@end
