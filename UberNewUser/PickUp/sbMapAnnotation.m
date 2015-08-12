//
//  SBMapAnnotation.m
//  SnakeBite
//
//  Created by Tejas Jasani on 07/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBMapAnnotation.h"

@implementation SBMapAnnotation

@synthesize coordinate,title,subtitle,yTag,pinColor;
- (id)initWithCoordinate:(CLLocationCoordinate2D) inCoordinate {
    coordinate = inCoordinate;
    return self;
}

@end