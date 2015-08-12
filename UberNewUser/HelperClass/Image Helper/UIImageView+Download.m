//
//  UIImageView+Download.m
//  SalesPoint
//
//  Created by Elluminati - macbook on 09/10/13.
//  Copyright (c) 2013 Elluminati MacBook Pro 1. All rights reserved.
//

#import "UIImageView+Download.h"
#import "AppDelegate.h"
@implementation UIImageView (Download)


-(void)downloadFromURL:(NSString *)url
{
    if (url) {
        if ([url rangeOfString:@"/Caches/"].location != NSNotFound) {
            return;
        }
        
        NSString *strImgName = [[[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"] lastObject];
        AppDelegate *app=[[UIApplication sharedApplication]delegate];
        
        [app applicationCacheDirectoryString];
        NSString *imagePath = [NSString stringWithFormat:@"%@%@",[app applicationCacheDirectoryString],strImgName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *aURL=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if ([fileManager fileExistsAtPath:imagePath]==NO)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void) {
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aURL]];
                [imageData writeToFile:imagePath atomically:YES];
                
                
                ////NSLog((@"pre writing to file"));
                if (![imageData writeToFile:imagePath atomically:NO])
                {
                    ////NSLog((@"Failed to cache image data to disk"));
                }
                else
                {
                    ////NSLog(@"the cachedImagedPath is %@",imagePath);
                    
                }
                //Store local //imagePath
            });
        }
    }
}

-(void)downloadFromURL:(NSString *)url withPlaceholder:(UIImage *)placehold
{
    if (placehold) {
        [self setImage:placehold];
    }
    if (url) {
        
        UIActivityIndicatorView *ai=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((self.frame.size.width-37)/2, (self.frame.size.height-37)/2, 37, 37)];
        [ai setHidesWhenStopped:YES];
        ai.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
        [ai setTintColor:[UIColor redColor]];
        [self addSubview:ai];
        [ai startAnimating];
        
        if ([url rangeOfString:@"/Library/"].location != NSNotFound)
        {
            [ai stopAnimating];
            ai = nil;
            NSData *imageData=[NSData dataWithContentsOfFile:url];
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                [self setImage:image];
                [self setNeedsLayout];
                imageData = nil;
            }
            return;
        }
        
        NSString *strImgName = [[[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"] lastObject];
        AppDelegate *app=[[UIApplication sharedApplication]delegate];
        
        [app applicationCacheDirectoryString];
        
        // NSString *imagePath = [NSString stringWithFormat:@"%@%@",[[AppDelegate sharedObject]applicationCacheDirectoryString],strImgName];
        
        
        NSString *imagePath = [NSString stringWithFormat:@"%@%@",[app applicationCacheDirectoryString],strImgName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *aURL=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if ([fileManager fileExistsAtPath:imagePath]==NO)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void) {
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aURL]];
                //[imageData writeToFile:imagePath atomically:YES];

                UIImage* image = [[UIImage alloc] initWithData:imageData];
                UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:image];
                NSData *dataS = UIImagePNGRepresentation(imgUpload);
                [dataS writeToFile:imagePath atomically:YES];
                
                imageData = nil;
                if (imgUpload) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ai stopAnimating];
                        [self setImage:imgUpload];
                        [self setNeedsLayout];
                    });
                }
                else
                {
                    [ai stopAnimating];
                }
            });
        }
        else{
            [ai stopAnimating];
            ai = nil;
            NSData *imageData=[NSData dataWithContentsOfFile:imagePath];
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                [self setImage:image];
                [self setNeedsLayout];
            }
            imageData = nil;
        }
    }
}

/*
 - (NSString *)applicationCacheDirectoryString
 {
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
 NSString *cacheDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
 return cacheDirectory;
 }
 */

@end
