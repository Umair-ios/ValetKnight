//
//  ForgetPasswordVC.m
//  UberforXOwner
//
//  Created by Deep Gami on 14/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ForgetPasswordVC.h"

@interface ForgetPasswordVC ()

@end

@implementation ForgetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBackBarItem];
    self.btnSend=[APPDELEGATE setBoldFontDiscriptor:self.btnSend];
    self.txtEmail.font=[UberStyleGuide fontRegular:14.0f];
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

- (IBAction)signBtnPressed:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"SENDING MAIL", nil)];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
        
        if ([[AppDelegate sharedAppDelegate]connected]) {
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_FORGET_PASSWORD withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                 if (response)
                 {
                     if([[response valueForKey:@"success"] boolValue])
                     {
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"PASSWORD_SENT", nil)];
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                     else
                     {
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
                         
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
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
