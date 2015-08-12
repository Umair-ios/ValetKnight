//
//  RatingBar.h
//  SampleRatingBar
//
//  Created by Prince Kumar Sharma on 08/03/13.
//  Copyright (c) 2013 Prince Kumar Sharma All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    rb0,
    rb1_h,
    rb1,
    rb2_h,
    rb2,
    rb3_h,
    rb3,
    rb4_h,
    rb4,
    rb5_h,
    rb5
}RBRatings;

@interface RatingBar : UIView
{
    @private
    CGSize imageSize;
    RBRatings ratingPoint;
}

-(id)initWithSize:(CGSize)size AndPosition:(CGPoint)position;
-(RBRatings)getcurrentRatings;
-(void)setRatings:(RBRatings)rate;
- (void)initRateBar;
@end