//
//  WAGLocation.h
//  Wag
//
//  Created by Jeremy Nelson on 9/11/14.
//  Copyright (c) 2014 Wag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WAGLocation : NSObject <MKAnnotation>

@property (nonatomic, assign) BOOL isHome;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end
