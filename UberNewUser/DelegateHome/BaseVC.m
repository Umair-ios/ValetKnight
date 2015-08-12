//
//  BaseVC.m
//  Employee
//
//  Created by Elluminati - macbook on 19/05/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "BaseVC.h"


@interface BaseVC ()

@end

@implementation BaseVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    animPop=YES;
    /*
    UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    btnLeft.frame=CGRectMake(0, 0, 18, 16);
    [btnLeft setImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
     */
    /*
    if (ISIOS7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    */
}
/*
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
*/

#pragma mark -
#pragma mark - Utility Methods

-(void)setNavBarTitle:(NSString *)title
{
    UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    lbl.textAlignment=NSTextAlignmentCenter;
    lbl.backgroundColor=[UIColor clearColor];
    lbl.font=[UIFont systemFontOfSize:16.0];
    lbl.textColor=[UIColor whiteColor];
    lbl.text=title;
    //self.navigationItem.titleView=lbl;
}

-(void)setBackBarItem
{
    self.navigationItem.hidesBackButton = YES;
    //self.navigationItem.backBarButtonItem = nil;
    UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    btnLeft.frame=CGRectMake(0, 0, 25, 25);
    //btnLeft.frame=CGRectMake(0, 0, 18, 16);
    //[btnLeft setImage:[UIImage imageNamed:@"icon_header"] forState:UIControlStateNormal];
    //[btnLeft setTitle:@"Back" forState:UIControlStateNormal];
    //[btnLeft setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(onClickBackBarItem:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
    [btnLeft setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
}

-(void)setBackBarItem:(BOOL)animated
{
    animPop=animated;
    [self setBackBarItem];
}

-(void)onClickBackBarItem:(id)sender
{
    [self.navigationController popViewControllerAnimated:animPop];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end


/*

 #pragma mark -
 #pragma mark - KeyBord Methods
 
 -(void) keyboardWillShow:(NSNotification *)note{
 // get keyboard size and loctaion
 CGRect keyboardBounds;
 [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
 NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
 NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
 
 // Need to translate the bounds to account for rotation.
 keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
 //for get keybord height
 //CGFloat kbHeight = [[note objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
 
 CGRect containerFrame = self.bottomView.frame;
 containerFrame.origin.y=self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
 [self.view bringSubviewToFront:self.bottomView];
 
 // animations settings
 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationBeginsFromCurrentState:YES];
 [UIView setAnimationDuration:[duration doubleValue]];
 [UIView setAnimationCurve:[curve intValue]];
 // set views with new info
 self.bottomView.frame=containerFrame;
 // commit animations
 [UIView commitAnimations];
 }
 
 -(void) keyboardWillHide:(NSNotification *)note{
 NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
 NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
 
 CGRect containerFrame = self.bottomView.frame;
 containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
 
 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationBeginsFromCurrentState:YES];
 [UIView setAnimationDuration:[duration doubleValue]];
 [UIView setAnimationCurve:[curve intValue]];
 
 // set views with new info
 self.bottomView.frame = containerFrame;
 // commit animations
 [UIView commitAnimations];
 }
 */

