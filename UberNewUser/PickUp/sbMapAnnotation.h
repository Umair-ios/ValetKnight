//
//  SBMapAnnotation.h
//  SnakeBite
//
//  Created by Tejas Jasani on 07/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SBMapAnnotation : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D coordinate;
    NSString *title, *subtitle;
    int yTag;
    MKPinAnnotationColor pinColor;
 
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title, *subtitle;
@property (nonatomic, readwrite) int yTag;
@property (nonatomic,readwrite) MKPinAnnotationColor pinColor;
- (id)initWithCoordinate:(CLLocationCoordinate2D) inCoordinate;

@end