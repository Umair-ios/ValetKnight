//
//  WAGLocation.m
//  Wag
//
//  Created by Jeremy Nelson on 9/11/14.
//  Copyright (c) 2014 Wag. All rights reserved.
//

#import "WAGLocation.h"
#import <AddressBook/AddressBook.h>

@interface WAGLocation ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end


@implementation WAGLocation

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Unknown name";
        }
        self.address = address;
        
        if (CLLocationCoordinate2DIsValid(coordinate)) {
            self.coordinate = coordinate;
        } else {
            ////NSLog(@"invalid coordinates");
        }
    }
    return self;
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return self.address;
}

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end
