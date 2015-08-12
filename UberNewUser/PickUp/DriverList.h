//
//  DriverList.h
//  TaxiNow
//
//  Created by AC on 11/02/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverList : NSObject

@property (weak, nonatomic) NSString *basePrice;
@property (weak, nonatomic) NSString *distance;
@property (weak, nonatomic) NSString *distanceCost;
@property (weak, nonatomic) NSString *idVal;
@property (weak, nonatomic) NSString *latitude;
@property (weak, nonatomic) NSString *longitude;
@property (weak, nonatomic) NSString *timeCost;
@property (weak, nonatomic) NSString *type;
@property (nonatomic, readwrite) int index;

@end
