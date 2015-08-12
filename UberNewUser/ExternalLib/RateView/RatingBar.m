//
//  RatingBar.m
//  SampleRatingBar
//
//  Created by Prince Kumar Sharma on 08/03/13.
//  Copyright (c) 2013 Prince Kumar Sharma All rights reserved.
//

#import "RatingBar.h"

@implementation RatingBar

-(id)initWithSize:(CGSize)size AndPosition:(CGPoint)position
{
    CGRect rect=CGRectMake(position.x, position.y, size.width, size.height);
    if (self==[super initWithFrame:rect]) {
        ////NSLog(@"self frame is %f,%f,%f,%f",position.x,position.y,size.width,size.height);
        ////NSLog(@"self frame is %f,%f,%f,%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
        
        imageSize=CGSizeMake(size.width/5,size.height);
        
        ratingPoint=rb0;
        int x=0;
        
        for (int i=0;i<5;i++) {
           [self addSubview:[self imageViewWithFrame:CGRectMake(x, 0, imageSize.width, imageSize.height) andTag:i+1]];
            x+=imageSize.width;
        }
    }
    return self;
}

- (void)initRateBar
{
    CGRect rect=self.frame;
    
    imageSize=CGSizeMake(rect.size.width/5,rect.size.height);
    
    ratingPoint=rb0;
    int x=0;
    
    for (int i=0;i<5;i++) {
        [self addSubview:[self imageViewWithFrame:CGRectMake(x, 0, imageSize.width, imageSize.height) andTag:i+1]];
        x+=imageSize.width;
    }
}


-(void)fillStartillPoint:(CGPoint)point
{
    

    if (point.x<imageSize.width/2 && point.x>0)
    {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"hf.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
        ratingPoint=rb1_h;
    }
    
    if (point.x<imageSize.width && point.x>=imageSize.width/2) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
        ratingPoint=rb1;
    }
    
    if (point.x<imageSize.width*2-imageSize.width/2  && point.x>=imageSize.width) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"hf.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
        ratingPoint=rb2_h;
    }
    
    if (point.x<imageSize.width*2 && point.x>=imageSize.width*2-imageSize.width/2) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
        
        ratingPoint=rb2;
    }
    
    if (point.x<imageSize.width*3-imageSize.width/2 && point.x>=imageSize.width*2) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"hf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
        ratingPoint=rb3_h;
    }
    
    if (point.x<imageSize.width*3 && point.x>=imageSize.width*3-imageSize.width/2) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
        ratingPoint=rb3;
    }
    
    if (point.x<imageSize.width*4-imageSize.width/2 && point.x>=imageSize.width*3) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"hf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
        ratingPoint=rb4_h;
    }
    
    if (point.x<imageSize.width*4 && point.x>=imageSize.width*4-imageSize.width/2) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
        ratingPoint=rb4;
    }
    
    if (point.x<imageSize.width*5-imageSize.width/2 && point.x>=imageSize.width*4) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"hf.png"]];
        ratingPoint=rb5_h;
    }
    
    if (point.x<imageSize.width*5 && point.x>=imageSize.width*5-imageSize.width/2) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"ff.png"]];
        ratingPoint=rb5;
    }
}

-(void)setRatings:(RBRatings)rate
{
    ratingPoint=rate;
    
    if (rate==rb0)
    {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb1_h) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"hf.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb1) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb2_h) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"hf.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb2) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb3_h) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"hf.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb3) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"nf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb4_h) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"hf.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb4) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"nf.png"]];
    }
    
    if (rate==rb5_h) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"hf.png"]];
    }
    
    if (rate==rb5) {
        [[self imageViewAtIndex:1] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:2] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:3] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:4] setImage:[UIImage imageNamed:@"ff.png"]];
        [[self imageViewAtIndex:5] setImage:[UIImage imageNamed:@"ff.png"]];
    }
}

-(RBRatings)getcurrentRatings
{
    return ratingPoint;
}

-(UIImageView*)imageViewAtIndex:(int)index
{
   return  (UIImageView*)[self viewWithTag:index];
}

-(UIImageView*)imageViewWithFrame:(CGRect)rect andTag:(int)itag
{
    UIImageView *image=[[UIImageView alloc] initWithFrame:rect];
    [image setImage:[UIImage imageNamed:@"nf.png"]];
    [image setTag:itag];
    return image;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint pt=[touch locationInView:self];
    
    if ((pt.x>=0 && pt.x<=self.frame.size.width) && (pt.y>0 && pt.y<=self.frame.size.height)) {
        
        [self fillStartillPoint:pt];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint pt=[touch locationInView:self];
    
    if ((pt.x>=0 && pt.x<=self.frame.size.width) && (pt.y>0 && pt.y<=self.frame.size.height)) {
        [self fillStartillPoint:pt];
    }
}

@end
