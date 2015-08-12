//
//  ForgetPasswordVC.h
//  UberforXOwner
//
//  Created by Deep Gami on 14/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"

@interface ForgetPasswordVC : BaseVC <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
- (IBAction)signBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@end
