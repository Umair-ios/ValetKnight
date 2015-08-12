//
//  LoginVC.h
//  Uber
//
//  Created by Elluminati - macbook on 21/06/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "BaseVC.h"
#import "Reachability.h"

@interface LoginVC : BaseVC<UITextFieldDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPsw;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;

@property NetworkStatus internetConnectionStatus;
@property(nonatomic,weak)IBOutlet UIScrollView *scrLogin;
@property(nonatomic,weak)IBOutlet UITextField *txtEmail;
@property(nonatomic,weak)IBOutlet UITextField *txtPsw;

- (IBAction)onClickGooglePlus:(id)sender;
- (IBAction)onClickFacebook:(id)sender;

-(IBAction)onClickLogin:(id)sender;
-(IBAction)onClickForgotPsw:(id)sender;

@end
