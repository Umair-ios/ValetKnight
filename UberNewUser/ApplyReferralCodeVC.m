//
//  ApplyReferralCodeVC.m
//  UberforXOwner
//
//  Created by Deep Gami on 22/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ApplyReferralCodeVC.h"
#import "Constants.h"
#import "AFNHelper.h"
#import "AppDelegate.h"

@interface ApplyReferralCodeVC ()

@end

@implementation ApplyReferralCodeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    
    self.txtCode.delegate = self;
    self.txtCode.font=[UberStyleGuide fontRegular];
    self.btnSubmit=[APPDELEGATE setBoldFontDiscriptor:self.btnSubmit];
    self.btnContinue=[APPDELEGATE setBoldFontDiscriptor:self.btnContinue];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)codeBtnPressed:(id)sender {
    
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:@"Verifying"];
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:strForUserId forKey:PARAM_ID];
        [dictParam setObject:self.txtCode.text forKey:PARAM_ADD_PROMO_REF];
        [dictParam setObject:strForUserToken forKey:PARAM_TOKEN];
        
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_APPLY_REFERRAL withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 ////NSLog(@"APPLY REF - %@",response);
                 if([[response valueForKey:@"success"]boolValue] == TRUE)
                 {
                     [self.view endEditing:YES];
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"SUCESS_REFERRAL", nil)];
                     [self performSegueWithIdentifier:@"segueToAddPayment" sender:self];
                 }
                 else
                 {
                     [APPDELEGATE showToastMessage:[response valueForKey:@"error"]];
                 }
             }
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (IBAction)ContinueBtnPressed:(id)sender
{
    [self performSegueWithIdentifier:@"segueToAddPayment" sender:self];
}

#pragma mark-
#pragma mark- TextField Delegate



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtCode resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
