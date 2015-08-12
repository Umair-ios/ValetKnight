//
//  BaseVC.h
//  Employee
//
//  Created by Elluminati - macbook on 19/05/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseVC : UIViewController
{
    BOOL animPop;
}
-(void)setBackBarItem;
-(void)setBackBarItem:(BOOL)animated;
-(void)setNavBarTitle:(NSString *)title;

@end
