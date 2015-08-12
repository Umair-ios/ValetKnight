//
//  ApplyReferralCodeVC.h
//  UberforXOwner
//
//  Created by Deep Gami on 22/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplyReferralCodeVC : UIViewController <UITextFieldDelegate>
- (IBAction)codeBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtCode;
- (IBAction)ContinueBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@end
