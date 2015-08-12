//
//  ReferralCodeVC.m
//  UberforXOwner
//
//  Created by Deep Gami on 21/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ReferralCodeVC.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNHelper.h"
#import <Social/Social.h>

@interface ReferralCodeVC () {
    NSString *strForReferralCode, *strForCredits;
}

@property (weak, nonatomic) IBOutlet UIView *addReferralView;
@property (weak, nonatomic) IBOutlet UITextField *referralTxt;
@property (weak, nonatomic) IBOutlet UIButton *btnEditReferral;
@property (weak, nonatomic) IBOutlet UIView *addPromotionsView;
@property (weak, nonatomic) IBOutlet UITextField *promoCodeTxt;
@property (weak, nonatomic) IBOutlet UILabel *creditsLbl;
@property (weak, nonatomic) IBOutlet UILabel *refLbl;
@property (weak, nonatomic) IBOutlet UILabel *shareReferralLbl;
@property (weak, nonatomic) IBOutlet UIView *shareView;

@end

@implementation ReferralCodeVC
@synthesize dictContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setBackBarItem];
    
    if (dictContent != nil) {
        [self.btnNavigation setTitle:[NSString stringWithFormat:@"  %@",[dictContent valueForKey:@"title"]] forState:UIControlStateNormal];
        [self.btnNavigation setImage:[UIImage imageNamed:[dictContent valueForKey:@"titleImg"]] forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[dictContent valueForKey:@"title"] isEqual:@"PROMOTIONS"]) {
        [self.addPromotionsView setHidden:NO];
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForCredits=[pref valueForKey:PREF_CREDITS];
        strForReferralCode=[pref valueForKey:PREF_REFERRAL_CODE];
        
        [self getCredits];
        
        if (strForReferralCode==nil) {
            self.refLbl.text = @"Not yet added";
        }
        else {
            self.refLbl.text = strForReferralCode;
        }
    }
    else if ([[dictContent valueForKey:@"title"] isEqual:@"FREE RIDES"]) {
        [self.addPromotionsView setHidden:YES];
        
        [self.addReferralView setHidden:YES];
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForReferralCode=[pref valueForKey:PREF_REFERRAL_CODE];
        
        if (strForReferralCode==nil) {
            [self.btnEditReferral setTitle:@"ADD" forState:UIControlStateNormal];
            [self.shareReferralLbl setText:@"Thanks for signing up with TaxiNow! Create a referral code and share with your friends to earn free rides!"];
            [self.shareView setHidden:YES];
            [self getReferralCode];
        }
        else {
            [self.btnEditReferral setTitle:@"EDIT" forState:UIControlStateNormal];
            [self.shareReferralLbl setText:@"Thanks for signing up with TaxiNow! Share your referral code with your friends to earn free rides!"];
            [self.shareView setHidden:NO];
            self.lblCode.text=strForReferralCode;
        }
    }
    
    self.btnNavigation.titleLabel.font=[UberStyleGuide fontRegular];
    //self.btnShare.titleLabel.font=[UberStyleGuide fontRegularBold];
    self.lblCode.font=[UberStyleGuide fontRegularBold:20.0f];
    self.lblYour.font=[UberStyleGuide fontRegular:15.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getReferralCode
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [APPDELEGATE showLoadingWithTitle:@"Getting your referral code"];
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_REFERRAL,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 [APPDELEGATE hideLoadingView];
                 if([[response valueForKey:@"success"]boolValue] == TRUE)
                 {
                     ////NSLog(@"hi");
                     strForReferralCode=[response valueForKey:@"referral_code"];
                     
                     [pref setObject:strForReferralCode forKey:PREF_REFERRAL_CODE];
                     [pref synchronize];
                     self.lblCode.text=strForReferralCode;
                     [self.btnEditReferral setTitle:@"EDIT" forState:UIControlStateNormal];
                     [self.shareReferralLbl setText:@"Thanks for signing up with TaxiNow! Share your referral code with your friends to earn free rides!"];
                     [self.shareView setHidden:NO];
                  }
                 else
                 {}
             }
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)shareBtnPressed:(id)sender
{
    [self shareMail];
}

-(void)shareMail
{
    if(strForReferralCode)
    {
        
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer=[[MFMailComposeViewController alloc]init ];
            mailer.mailComposeDelegate=self;
            //NSArray *toRecipients=[[NSArray alloc]initWithObjects:@"",nil];
            NSString *msg=[NSString stringWithFormat:@"Sign up for Uber For X with my referral code %@, and get free rides!",strForReferralCode];
            [mailer setSubject:@"SHARE REFERRAL CODE"];
            [mailer setMessageBody:msg isHTML:NO];
            // [mailer setToRecipients:toRecipients];
            
            //  NSData *dataObj = UIImageJPEGRepresentation(shareImage, 1);
            // [mailer addAttachmentData:dataObj mimeType:@"image/jpeg" fileName:@"iBusinessCard.jpg"];
            
            [mailer setDefinesPresentationContext:YES];
            [mailer setEditing:YES];
            [mailer setModalInPopover:YES];
            [mailer setNavigationBarHidden:NO animated:YES];
            [mailer setWantsFullScreenLayout:YES];
            
            [self presentViewController:mailer animated:YES completion:nil];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                            message:@"Your device doesn't support the composer sheet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            
        }
    }
    else
        
    {
        [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_REFERRAL", nil)];
        
    }
    
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            ////NSLog(@"Mail send canceled");
            [self.tabBarController setSelectedIndex:0];
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
        case MFMailComposeResultSent:
            [self showAlert:@"Mail sent successfully." message:@"Success"];
            [self dismissViewControllerAnimated:YES completion:NULL];
            
            ////NSLog(@"Mail send successfully");
            break;
        case MFMailComposeResultSaved:
            [self showAlert:@"Mail saved to drafts successfully." message:@"Mail saved"];
            ////NSLog(@"Mail Saved");
            break;
        case MFMailComposeResultFailed:
            [self showAlert:[NSString stringWithFormat:@"Error:%@.", [error localizedDescription]] message:@"Failed to send mail"];
            ////NSLog(@"Mail send error : %@",[error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)editReferralEvent:(id)sender {
    if ([self.addReferralView isHidden]) {
        [self.addReferralView setHidden:NO];
        [self.referralTxt becomeFirstResponder];
    }
    else {
        [self.referralTxt resignFirstResponder];
        [self.addReferralView setHidden:YES];
    }
}

- (IBAction)addReferralEvent:(id)sender {
    if ([self.referralTxt.text isEqualToString:@""]) {
        [self.view endEditing:YES];
        [APPDELEGATE showToastMessage:@"Please enter a referral code"];
    }
    else {
        [self addReferralCode];
    }
}

-(void)addReferralCode
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
        [dictParam setObject:strForUserId forKey:PARAM_ID];
        [dictParam setObject:strForUserToken forKey:PARAM_TOKEN];
        [dictParam setObject:self.referralTxt.text forKey:PARAM_ADD_PROMO_REF];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_REFERRAL withParamData:dictParam withBlock:^(id response, NSError *error) {
            if (response) {
                if([[response valueForKey:@"success"]boolValue] == TRUE) {
                    strForReferralCode=self.referralTxt.text;
                    [pref setObject:strForReferralCode forKey:PREF_REFERRAL_CODE];
                    [pref synchronize];
                    [self.view endEditing:YES];
                    
                    self.lblCode.text=strForReferralCode;
                    [self.btnEditReferral setTitle:@"EDIT" forState:UIControlStateNormal];
                    [self.shareReferralLbl setText:@"Thanks for signing up with TaxiNow! Share your referral code with your friends to earn free rides!"];
                    [self.addReferralView setHidden:YES];
                    [self.shareView setHidden:NO];
                }
                else {
                    [self.view endEditing:YES];
                    
                    [self.addReferralView setHidden:NO];
                    [self.shareView setHidden:YES];
                    //[self.btnEditReferral setTitle:@"EDIT" forState:UIControlStateNormal];
                    [self.shareReferralLbl setText:@"Thanks for signing up with TaxiNow! Create a referral code and share with your friends to earn free rides!"];
                    [APPDELEGATE showToastMessage:@"OOPS!! Something went wrong. Try Again"];
                }
            }
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

-(void) getCredits {
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_CREDITS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue] == TRUE)
                 {
                     strForCredits=[NSString stringWithFormat:@"%@ %@",[[response valueForKey:@"credits"] objectForKey:@"currency"],[[response valueForKey:@"credits"] objectForKey:@"balance"]];
                     self.creditsLbl.text = strForCredits;
                     
                     [pref setObject:strForCredits forKey:PREF_CREDITS];
                     [pref synchronize];
                 }
                 else {
                     self.creditsLbl.text = @"-.--";
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

- (IBAction)applyPromoCodeEvent:(id)sender {
    [self.view endEditing:YES];
    [self applyPromo];
}

-(void) applyPromo {
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:@"CHECKING PROMO CODE"];
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:strForUserId forKey:PARAM_ID];
        [dictParam setObject:self.promoCodeTxt.text forKey:PARAM_ADD_PROMO_REF];
        [dictParam setObject:strForUserToken forKey:PARAM_TOKEN];
        
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_APPLY_REFERRAL withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     ////NSLog(@"APPLY PROMO - %@",response);
                     if([[response valueForKey:@"success"]boolValue]) {
                         [self.view endEditing:YES];
                         [self getCredits];
                     }
                 }
                 else {
                     [self.view endEditing:YES];
                     NSString *error_code = [NSString stringWithFormat:@"%@",[response valueForKey:@"error_code"]];
                     
                     if ([error_code isEqual:@"465"]) {
                         [APPDELEGATE showToastMessage:[NSString stringWithFormat:@"Use promo code %@ while taking a new ride",self.promoCodeTxt.text]];
                         self.promoCodeTxt.text = @"";
                     }
                     else if ([error_code isEqual:@"475"]) {
                         [APPDELEGATE showToastMessage:@"Invalid Promo code"];
                     }
                     else if ([error_code isEqual:@"485"]) {
                         [APPDELEGATE showToastMessage:@"Invalid Promo code"];
                     }
                     else if ([error_code isEqual:@"495"]) {
                         [APPDELEGATE showToastMessage:@"Promo already applied"];
                     }
                     else if ([error_code isEqual:@"496"]) {
                         [APPDELEGATE showToastMessage:@"Invalid Promo code"];
                     }
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.promoCodeTxt]) {
        [self applyPromo];
        [textField resignFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)fbShare {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *fbPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        NSString *msg=[NSString stringWithFormat:@"Sign up for TaxiNow with my referral code %@, and get free rides!",strForReferralCode];
        [fbPost setInitialText:msg];
        
        [self presentViewController:fbPost animated:YES completion:Nil];
    }
    else {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:@"http://staging.taxinow.xyz/"];
        content.contentTitle = [NSString stringWithFormat:@"Sign up for TaxiNow with my referral code %@, and get free rides!",strForReferralCode];
        
//        [FBSDKShareAPI shareWithContent:content delegate:nil];
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
        //[APPDELEGATE showToastMessage:@"Please Configure facebook in your phone"];
    }
}

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    ////NSLog(@"%@",results);
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    ////NSLog(@"%@",error);
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    ////NSLog(@"Fb share cancelled");
}

-(void)tweetShare {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSString *msg=[NSString stringWithFormat:@"Sign up for TaxiNow with my referral code %@, and get free rides!",strForReferralCode];
        [tweet setInitialText:msg];
        
        [self presentViewController:tweet animated:YES completion:Nil];
    }
    else {
        //[APPDELEGATE showToastMessage:@"Please Configure twitter in your phone"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ////NSLog(@"%ld",(long)buttonIndex);
    
    if (buttonIndex == 1) {
        if (&UIApplicationOpenSettingsURLString != NULL) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
        else {
            // Present some dialog telling the user to open the settings app.
        }
    }
}

-(void)textShare {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *msg=[NSString stringWithFormat:@"Sign up for TaxiNow with my referral code %@, and get free rides!",strForReferralCode];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    //[messageController setRecipients:recipents];
    [messageController setBody:msg];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)fbShareEvent:(id)sender {
    [self.view endEditing:YES];
    [self fbShare];
}

- (IBAction)twitterShareEvent:(id)sender {
    [self.view endEditing:YES];
    [self tweetShare];
}

- (IBAction)textShareEvent:(id)sender {
    [self.view endEditing:YES];
    [self textShare];
}


@end
