//
//  RegisterVC.h
//  Uber
//
//  Created by Elluminati - macbook on 23/06/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "BaseVC.h"

@interface RegisterVC : BaseVC<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>
{
    
}

///// Outlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtBio;
@property (weak, nonatomic) IBOutlet UITextField *txtZipCode;
@property (weak, nonatomic) IBOutlet UIButton *btnProPic;
@property (weak, nonatomic) IBOutlet UIView *viewForPicker;
@property (weak, nonatomic) IBOutlet UIImageView *imgProPic;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIButton *btnTerms;

@property (weak, nonatomic) IBOutlet UIButton *btnSelectCountry;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectTimeZone;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;

////// Actions
- (IBAction)pickerCancelBtnPressed:(id)sender;
- (IBAction)pickerDoneBtnPressed:(id)sender;

- (IBAction)fbbtnPressed:(id)sender;
- (IBAction)proPicBtnPressed:(id)sender;
- (IBAction)selectCountryBtnPressed:(id)sender;

- (IBAction)googleBtnPressed:(id)sender;
- (IBAction)nextBtnPressed:(id)sender;

- (IBAction)checkBoxBtnPressed:(id)sender;
- (IBAction)termsBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnNav_Register;


@end
