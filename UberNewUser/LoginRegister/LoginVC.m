//
//  LoginVC.m
//  Uber
//
//  Created by Elluminati - macbook on 21/06/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "LoginVC.h"
#import "FacebookUtility.h"
#import <GooglePlus/GooglePlus.h>
#import "AppDelegate.h"
#import "GooglePlusUtility.h"
#import "AFNHelper.h"
#import "Constants.h"
#import "UtilityClass.h"

@interface LoginVC ()
{
    NSString *strForSocialId,*strLoginType,*strForEmail;
    AppDelegate *appDelegate;
    
}

@end

@implementation LoginVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setNavBarTitle:TITLE_LOGIN];
    [super setBackBarItem];
    
    [self.txtEmail setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtPsw setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    strLoginType=@"manual";
    
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtPsw.font=[UberStyleGuide fontRegular];
    
    self.btnSignIn=[APPDELEGATE setBoldFontDiscriptor:self.btnSignIn];
    self.btnForgotPsw=[APPDELEGATE setBoldFontDiscriptor:self.btnForgotPsw];
    self.btnSignUp=[APPDELEGATE setBoldFontDiscriptor:self.btnSignUp];
    
    /*self.txtEmail.text=@"deep.gami077@gmail.com";
     self.txtPsw.text=@"123123";*/
    
    //[self performSegueWithIdentifier:SEGUE_SUCCESS_LOGIN sender:self];
    
}
/*
 -(void)viewWillAppear:(BOOL)animated
 {
 [super viewWillAppear:animated];
 self.navigationController.navigationBarHidden=YES;
 }
 
 -(void)viewWillDisappear:(BOOL)animated
 {
 self.navigationController.navigationBarHidden=NO;
 [super viewWillDisappear:animated];
 }
 */
#pragma mark -
#pragma mark - Actions

- (IBAction)onClickGooglePlus:(id)sender
{
    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
    
    strLoginType=@"google";
    
    if ([[GooglePlusUtility sharedObject]isLogin])
    {
        [[GooglePlusUtility sharedObject]loginWithBlock:^(id response, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (response) {
                 ////NSLog(@"Gmail Response ->%@ ",response);
                 strForSocialId=[response valueForKey:@"userid"];
                 strForEmail=[response valueForKey:@"email"];
                 self.txtEmail.text=strForEmail;
                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
                 [self onClickLogin:nil];
                 
             }
         }];
    }
    else
    {
        [[GooglePlusUtility sharedObject]loginWithBlock:^(id response, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (response) {
                 ////NSLog(@"Gmail Response ->%@ ",response);
                 strForSocialId=[response valueForKey:@"userid"];
                 strForEmail=[response valueForKey:@"email"];
                 self.txtEmail.text=strForEmail;
                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
                 [self onClickLogin:nil];
                 
             }
         }];
    }
    
    
}

- (IBAction)onClickFacebook:(id)sender
{
    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
    
    strLoginType=@"facebook";
    
    if (![[FacebookUtility sharedObject]isLogin])
    {
        [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (success)
             {
                 ////NSLog(@"Success");
                 appDelegate = [UIApplication sharedApplication].delegate;
                 [appDelegate userLoggedIn];
                 [[FacebookUtility sharedObject]fetchMeWithFBCompletionBlock:^(id response, NSError *error) {
                     if (response) {
                         strForSocialId=[response valueForKey:@"id"];
                         strForEmail=[response valueForKey:@"email"];
                         self.txtEmail.text=strForEmail;
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         
                         [self onClickLogin:nil];
                         
                     }
                 }];
             }
         }];
    }
    else{
        ////NSLog(@"User Login Click");
        appDelegate = [UIApplication sharedApplication].delegate;
        [[FacebookUtility sharedObject]fetchMeWithFBCompletionBlock:^(id response, NSError *error) {
            [APPDELEGATE hideLoadingView];
            if (response) {
                strForSocialId=[response valueForKey:@"id"];
                strForEmail=[response valueForKey:@"email"];
                self.txtEmail.text=strForEmail;
                [[AppDelegate sharedAppDelegate]hideLoadingView];
                
                [self onClickLogin:nil];
            }
        }];
        [appDelegate userLoggedIn];
    }
    
}

-(IBAction)onClickLogin:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if(self.txtEmail.text.length>0)
        {
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOGIN", nil)];
            
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            NSString *strDeviceId=[pref objectForKey:PREF_DEVICE_TOKEN];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:@"ios" forKey:PARAM_DEVICE_TYPE];
            [dictParam setValue:strDeviceId forKey:PARAM_DEVICE_TOKEN];
            if([strLoginType isEqualToString:@"manual"])
                [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
            // else
            //     [dictParam setValue:strForEmail forKey:PARAM_EMAIL];
            
            [dictParam setValue:strLoginType forKey:PARAM_LOGIN_BY];
            
            if([strLoginType isEqualToString:@"facebook"])
                [dictParam setValue:strForSocialId forKey:PARAM_SOCIAL_UNIQUE_ID];
            else if ([strLoginType isEqualToString:@"google"])
                [dictParam setValue:strForSocialId forKey:PARAM_SOCIAL_UNIQUE_ID];
            else
                [dictParam setValue:self.txtPsw.text forKey:PARAM_PASSWORD];
            
            if ([[AppDelegate sharedAppDelegate]connected]) {
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_LOGIN withParamData:dictParam withBlock:^(id response, NSError *error)
                 {
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     
                     ////NSLog(@"Login Response ---> %@",response);
                     if (response)
                     {
                         if([[response valueForKey:@"success"]boolValue])
                         {
                             NSString *strLog=[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"LOGIN_SUCCESS", nil),[response valueForKey:@"first_name"]];
                             
                             [APPDELEGATE showToastMessage:strLog];
                             
                             
                             NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                             [pref setObject:response forKey:PREF_LOGIN_OBJECT];
                             [pref setObject:[response valueForKey:@"token"] forKey:PREF_USER_TOKEN];
                             [pref setObject:[response valueForKey:@"id"] forKey:PREF_USER_ID];
                             [pref setBool:YES forKey:PREF_IS_LOGIN];
                             [pref synchronize];
                             
                             [self performSegueWithIdentifier:SEGUE_SUCCESS_LOGIN sender:self];
                         }
                         else
                         {
                             
                             
                             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                             [alert show];
                         }
                     }
                     
                 }];
            }
            else
            {
                if(self.txtEmail.text.length==0)
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EMAIL", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    [alert show];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_PASSWORD", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

-(IBAction)onClickForgotPsw:(id)sender
{
    [self textFieldShouldReturn:self.txtPsw];
    /*
     if (self.txtEmail.text.length==0)
     {
     [[UtilityClass sharedObject]showAlertWithTitle:@"" andMessage:@"Enter your email id."];
     return;
     }
     else if (![[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
     {
     [[UtilityClass sharedObject]showAlertWithTitle:@"" andMessage:@"Enter valid email id."];
     return;
     }
     */
}

#pragma mark -
#pragma mark - TextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    int y=0;
    if (textField==self.txtEmail)
    {
        y=50;
    }
    else if (textField==self.txtPsw){
        y=100;
    }
    [self.scrLogin setContentOffset:CGPointMake(0, y) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.txtEmail)
    {
        [self.txtPsw becomeFirstResponder];
    }
    else if (textField==self.txtPsw){
        [textField resignFirstResponder];
        [self.scrLogin setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return YES;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
