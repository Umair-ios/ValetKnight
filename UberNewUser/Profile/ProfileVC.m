//
//  ProfileVC.m
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVBase.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "UtilityClass.h"
#import "UIView+Utils.h"

@interface ProfileVC ()
{
    NSString *strForUserId,*strForUserToken;
    NSMutableArray *arrForTimeZone;
    NSMutableDictionary *timeZoneDict;
    NSArray *timeZoneArr;
}

@property (weak, nonatomic) IBOutlet UIView *viewForPicker;
@property (weak, nonatomic) IBOutlet UIButton *btnTimeZone;

@end

@implementation ProfileVC

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
    //[super setNavBarTitle:TITLE_PROFILE];
    [super setBackBarItem];
    [self.proPicImgv applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    arrForTimeZone = [[NSMutableArray alloc]init];

    [self customFont];
    [self initialPrefs];
    
    [self setDataForUserInfo];
}

-(void)setDataForUserInfo
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];
    
    [self.proPicImgv downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    self.txtFirstName.text=[dictInfo valueForKey:@"first_name"];
    self.txtLastName.text=[dictInfo valueForKey:@"last_name"];
    self.txtEmail.text=[dictInfo valueForKey:@"email"];
    self.txtPhone.text=[dictInfo valueForKey:@"phone"];
    self.txtAddress.text=[dictInfo valueForKey:@"address"];
    self.txtZipCode.text=[dictInfo valueForKey:@"zipcode"];
    self.txtBio.text=[dictInfo valueForKey:@"bio"];
    
    NSString *setTzName = [[timeZoneDict allKeysForObject:[dictInfo valueForKey:@"timezone"]] firstObject];
    [self.btnTimeZone setTitle:setTzName forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)selectPhotoBtnPressed:(id)sender
{
    if ([self.btnUpdate isHidden]) {
        [self performSelector:@selector(editBtnPressed:) withObject:self];
    }
    else {
        UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
        UIActionSheet *actionpass;
        
        actionpass = [[UIActionSheet alloc] initWithTitle:@"Select a Profile Picture" delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SELECT_PHOTO", @""),NSLocalizedString(@"TAKE_PHOTO", @""),nil];
        actionpass.delegate=self;
        [actionpass showInView:window];
    }
}

- (IBAction)updateBtnPressed:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if([[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
        {
            
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"EDITING", nil)];
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            strForUserId=[pref objectForKey:PREF_USER_ID];
            strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
            NSString *strTimezone = [NSString stringWithFormat:@"%@",self.btnTimeZone.titleLabel.text];

            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
            [dictParam setValue:self.txtFirstName.text forKey:PARAM_FIRST_NAME];
            [dictParam setValue:self.txtLastName.text forKey:PARAM_LAST_NAME];
            [dictParam setValue:self.txtPhone.text forKey:PARAM_PHONE];
            [dictParam setValue:self.txtBio.text forKey:PARAM_BIO];
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            
            [dictParam setValue:self.txtAddress.text forKey:PARAM_ADDRESS];
            [dictParam setValue:@"" forKey:PARAM_STATE];
            [dictParam setValue:@"" forKey:PARAM_COUNTRY];
            [dictParam setValue:self.txtZipCode.text forKey:PARAM_ZIPCODE];
            [dictParam setValue:[timeZoneDict objectForKey:strTimezone] forKey:PARAM_TIME_ZONE];
            
            UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.proPicImgv.image];

            if ([[AppDelegate sharedAppDelegate]connected]) {
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_UPADTE withParamDataImage:dictParam andImage:imgUpload withBlock:^(id response, NSError *error) {
                
                [[AppDelegate sharedAppDelegate]hideLoadingView];
                if (response)
                {
                    if([[response valueForKey:@"success"] boolValue])
                    {
                        
                        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                        [pref setObject:response forKey:PREF_LOGIN_OBJECT];
                        [pref synchronize];
                        [self setDataForUserInfo];
                        [APPDELEGATE showToastMessage:NSLocalizedString(@"PROFILE_EDIT_SUCESS", nil)];
                        [self textDisable];
                        self.btnUpdate.hidden=YES;
                        self.btnEdit.hidden=NO;
                        [self.proPicImgv downloadFromURL:[response valueForKey:@"picture"] withPlaceholder:nil];

                        // [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"ERROR", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
                
                ////NSLog(@"REGISTER RESPONSE --> %@",response);
            }];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
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

- (IBAction)editBtnPressed:(id)sender {
    [self textEnable];
    [self.btnEdit setHidden:YES];
    [self.btnUpdate setHidden:NO];
    [self.txtFirstName becomeFirstResponder];
    //[APPDELEGATE showToastMessage:@"You Can Edit Your Profile"];
}

#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.txtFirstName.font=[UberStyleGuide fontRegularBold:18.0f];
    self.txtLastName.font=[UberStyleGuide fontRegularBold:18.0f];
    self.txtPhone.font=[UberStyleGuide fontRegular:14.0f];
    self.txtEmail.font=[UberStyleGuide fontRegular:14.0f];
    self.txtAddress.font=[UberStyleGuide fontRegular:14.0f];
    self.txtBio.font=[UberStyleGuide fontRegular:14.0f];
    self.txtZipCode.font=[UberStyleGuide fontRegular:14.0f];
    
    self.btnNavigation.titleLabel.font=[UberStyleGuide fontRegular];
    self.btnEdit.titleLabel.font=[UberStyleGuide fontRegularBold];
    self.btnUpdate.titleLabel.font=[UberStyleGuide fontRegularBold];
}


-(void)textDisable
{
    self.txtFirstName.enabled = NO;
    self.txtLastName.enabled = NO;
    self.txtEmail.enabled = NO;
    self.txtPhone.enabled = NO;
    self.txtAddress.enabled = NO;
    self.txtZipCode.enabled = NO;
    self.txtBio.enabled = NO;
    //self.btnProPic.enabled=NO;
    self.btnTimeZone.enabled = NO;
}

-(void)textEnable
{
    self.txtFirstName.enabled = YES;
    self.txtLastName.enabled = YES;
    self.txtEmail.enabled = YES;
    self.txtPhone.enabled = YES;
    self.txtAddress.enabled = YES;
    self.txtZipCode.enabled = YES;
    self.txtBio.enabled = YES;
    //self.btnProPic.enabled=YES;
    self.btnTimeZone.enabled = YES;
}
#pragma mark
#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
        {
            [self takePhoto];
        }
            break;
        case 0:
        {
            [self selectPhotos];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark
#pragma mark - Action to Share


- (void)selectPhotos
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

-(void)takePhoto
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark
#pragma mark - ImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.proPicImgv.image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)setImage:(UIImage *)image
{
    self.proPicImgv.image=image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark - UItextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    int y=0;
    if(textField==self.txtPhone)
        y=-100;
    else if(textField==self.txtAddress)
        y=-136;
    else if(textField==self.txtBio)
        y=-150;
    else if(textField==self.txtZipCode)
        y=-170;
    
    [UIView animateWithDuration:0.5 animations:^{
        
            self.view.frame=CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished)
     {
     }];
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.txtLastName)
    {
       
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    /*if (textField==self.txtFirstName)
    {
        [self.txtLastName becomeFirstResponder];
    }
    if (textField==self.txtLastName)
    {
         //[[UITextField appearance] setTintColor:[UIColor blackColor]];
        [self.txtEmail becomeFirstResponder];
    }
    if (textField==self.txtEmail)
    {
        [self.txtPhone becomeFirstResponder];
    }
    if (textField==self.txtPhone)
    {
     
        [self.txtAddress becomeFirstResponder];
    }
    if (textField==self.txtAddress)
    {
        [self.txtBio  becomeFirstResponder];
    }
    if (textField==self.txtBio)
    {
        [self.txtZipCode becomeFirstResponder];
    }*/

    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished)
     {
     }];
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)selectTimeZoneEvent:(id)sender {
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:nil];
    
    arrForTimeZone = [timeZoneArr mutableCopy];
    [self.pickerView reloadAllComponents];
    self.viewForPicker.hidden=NO;
}


- (IBAction)pickerCancelBtnEvent:(id)sender {
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];

    NSString *setTzName = [[timeZoneDict allKeysForObject:[dictInfo valueForKey:@"timezone"]] firstObject];
    [self.btnTimeZone setTitle:setTzName forState:UIControlStateNormal];

    [self.viewForPicker setHidden:YES];
}

- (IBAction)pickerDoneBtnEvent:(id)sender {
    NSInteger row;
    
    row = [self.pickerView selectedRowInComponent:0];
    [self.btnTimeZone setTitle:[arrForTimeZone objectAtIndex:row] forState:UIControlStateNormal];
    
    [self.viewForPicker setHidden:YES];
}

#pragma mark - UIPickerView Delegate and Datasource

- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.btnTimeZone setTitle:[arrForTimeZone objectAtIndex:row] forState:UIControlStateNormal];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
       return arrForTimeZone.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *strForTitle;
    strForTitle = [NSString stringWithFormat:@"%@",[arrForTimeZone objectAtIndex:row]];

    return strForTitle;
}


-(void) initialPrefs {
    self.btnEdit.hidden=NO;
    self.btnUpdate.hidden=YES;
    [self.txtFirstName setTintColor:[UIColor whiteColor]];
    [self.txtLastName setTintColor:[UIColor whiteColor]];
    
    [self textDisable];
    
    timeZoneArr = [NSArray arrayWithObjects:@"(UTC-11:00) Midway Island",@"(UTC-11:00) Samoa",@"(UTC-10:00) Hawaii",@"(UTC-09:00) Alaska",@"(UTC-08:00) Pacific Time (US & Canada)",@"(UTC-08:00) Tijuana",@"TC-07:00) Arizona",@"(UTC-07:00) Chihuahua",@"(UTC-07:00) La Paz",@"(UTC-07:00) Mazatlan",@"(UTC-07:00) Mountain Time (US & Canada)",@"(UTC-06:00) Central America",@"(UTC-06:00) Central Time (US & Canada)",@"(UTC-06:00) Guadalajara",@"(UTC-06:00) Mexico City",@"(UTC-06:00) Monterrey",@"(UTC-06:00) Saskatchewan",@"(UTC-05:00) Bogota",@"(UTC-05:00) Bogota",@"(UTC-05:00) Eastern Time (US & Canada)",@"(UTC-05:00) Indiana (East)",@"(UTC-05:00) Lima",@"(UTC-05:00) Quito",@"(UTC-04:00) Atlantic Time (Canada)",@"(UTC-04:30) Caracas",@"(UTC-04:00) La Paz",@"(UTC-04:00) Santiago",@"(UTC-03:30) Newfoundland",@"(UTC-03:00) Brasilia",@"(UTC-03:00) Buenos Aires",@"(UTC-03:00) Georgetown",@"(UTC-03:00) Greenland",@"(UTC-02:00) Mid-Atlantic",@"(UTC-01:00) Azores",@"(UTC-01:00) Cape Verde Is.",@"(UTC+00:00) Casablanca",@"(UTC+00:00) Edinburgh",@"(UTC+00:00) Greenwich Mean Time : Dublin",@"(UTC+00:00) Lisbon",@"(UTC+00:00) London",@"(UTC+00:00) Monrovia",@"(UTC+00:00) UTC",@"(UTC+01:00) Amsterdam",@"(UTC+01:00) Belgrade",@"(UTC+01:00) Berlin",@"(UTC+01:00) Bern",@"(UTC+01:00) Bratislava",@"(UTC+01:00) Brussels",@"(UTC+01:00) Budapest",@"(UTC+01:00) Copenhagen",@"(UTC+01:00) Ljubljana",@"(UTC+01:00) Madrid",@"(UTC+01:00) Paris",@"(UTC+01:00) Prague",@"(UTC+01:00) Rome",@"(UTC+01:00) Sarajevo",@"(UTC+01:00) Skopje",@"(UTC+01:00) Stockholm",@"(UTC+01:00) Vienna",@"(UTC+01:00) Warsaw",@"(UTC+01:00) West Central Africa",@"(UTC+01:00) Zagreb",@"(UTC+02:00) Athens",@"(UTC+02:00) Bucharest",@"(UTC+02:00) Cairo",@"(UTC+02:00) Harare",@"(UTC+02:00) Helsinki",@"(UTC+02:00) Istanbul",@"(UTC+02:00) Jerusalem",@"(UTC+02:00) Kyiv",@"(UTC+02:00) Pretoria",@"(UTC+02:00) Riga",@"(UTC+02:00) Sofia",@"(UTC+02:00) Tallinn",@"(UTC+02:00) Vilnius",@"(UTC+03:00) Baghdad",@"(UTC+03:00) Kuwait",@"(UTC+03:00) Minsk",@"(UTC+03:00) Nairobi",@"(UTC+03:00) Riyadh",@"(UTC+03:00) Volgograd",@"(UTC+03:30) Tehran",@"(UTC+04:00) Abu Dhabi",@"(UTC+04:00) Baku",@"(UTC+04:00) Moscow",@"(UTC+04:00) Muscat",@"(UTC+04:00) St. Petersburg",@"(UTC+04:00) Tbilisi",@"(UTC+04:00) Yerevan",@"(UTC+04:30) Kabul",@"(UTC+05:00) Islamabad",@"(UTC+05:00) Karachi",@"(UTC+05:00) Tashkent",@"(UTC+05:30) Chennai",@"(UTC+05:30) Kolkata",@"(UTC+05:30) Mumbai",@"(UTC+05:30) New Delhi",@"(UTC+05:30) Sri Jayawardenepura",@"(UTC+05:45) Kathmandu",@"(UTC+06:00) Almaty",@"(UTC+06:00) Astana",@"(UTC+06:00) Dhaka",@"(UTC+06:00) Ekaterinburg",@"(UTC+06:30) Rangoon",@"(UTC+07:00) Bangkok",@"(UTC+07:00) Hanoi",@"(UTC+07:00) Jakarta",@"(UTC+07:00) Novosibirsk",@"(UTC+08:00) Beijing",@"(UTC+08:00) Chongqing",@"(UTC+08:00) Hong Kong",@"(UTC+08:00) Krasnoyarsk",@"(UTC+08:00) Kuala Lumpur",@"(UTC+08:00) Perth",@"(UTC+08:00) Singapore",@"(UTC+08:00) Taipei",@"(UTC+08:00) Ulaan Bataar",@"(UTC+08:00) Urumqi",@"(UTC+09:00) Irkutsk",@"(UTC+09:00) Osaka",@"(UTC+09:00) Sapporo",@"(UTC+09:00) Seoul",@"(UTC+09:00) Tokyo",@"(UTC+09:30) Adelaide",@"(UTC+09:30) Darwin",@"(UTC+10:00) Brisbane",@"(UTC+10:00) Canberra",@"(UTC+10:00) Guam",@"(UTC+10:00) Hobart",@"(UTC+10:00) Melbourne",@"(UTC+10:00) Port Moresby",@"(UTC+10:00) Sydney",@"(UTC+10:00) Yakutsk",@"(UTC+11:00) Vladivostok",@"(UTC+12:00) Auckland",@"(UTC+12:00) Fiji",@"(UTC+12:00) International Date Line West",@"(UTC+12:00) Kamchatka",@"(UTC+12:00) Magadan",@"(UTC+12:00) Marshall Is.",@"(UTC+12:00) New Caledonia",@"(UTC+12:00) Solomon Is.",@"(UTC+12:00) Wellington",@"(UTC+13:00) Nuku'alofa", nil];
    
    timeZoneDict = [[NSMutableDictionary alloc]init];
    [timeZoneDict setObject:@"Pacific/Midway" forKey:@"(UTC-11:00) Midway Island"];
    [timeZoneDict setObject:@"Pacific/Samoa" forKey:@"(UTC-11:00) Samoa"];
    [timeZoneDict setObject:@"Pacific/Honolulu" forKey:@"(UTC-10:00) Hawaii"];
    [timeZoneDict setObject:@"US/Alaska" forKey:@"(UTC-09:00) Alaska"];
    [timeZoneDict setObject:@"America/Los_Angeles" forKey:@"(UTC-08:00) Pacific Time (US & Canada)"];
    [timeZoneDict setObject:@"America/Tijuana" forKey:@"(UTC-08:00) Tijuana"];
    [timeZoneDict setObject:@"US/Arizona" forKey:@"(UTC-07:00) Arizona"];
    [timeZoneDict setObject:@"America/Chihuahua" forKey:@"(UTC-07:00) Chihuahua"];
    [timeZoneDict setObject:@"America/Chihuahua" forKey:@"La Paz"];
    [timeZoneDict setObject:@"America/Mazatlan" forKey:@"(UTC-07:00) Mazatlan"];
    [timeZoneDict setObject:@"US/Mountain" forKey:@"(UTC-07:00) Mountain Time (US & Canada)"];
    [timeZoneDict setObject:@"America/Managua" forKey:@"(UTC-06:00) Central America"];
    [timeZoneDict setObject:@"US/Central" forKey:@"(UTC-06:00) Central Time (US & Canada)"];
    [timeZoneDict setObject:@"America/Mexico_City" forKey:@"(UTC-06:00) Guadalajara"];
    [timeZoneDict setObject:@"America/Mexico_City" forKey:@"(UTC-06:00) Mexico City"];
    [timeZoneDict setObject:@"America/Monterrey" forKey:@"(UTC-06:00) Monterrey"];
    [timeZoneDict setObject:@"Canada/Saskatchewan" forKey:@"(UTC-06:00) Saskatchewan"];
    [timeZoneDict setObject:@"America/Bogota" forKey:@"(UTC-05:00) Bogota"];
    [timeZoneDict setObject:@"US/Eastern" forKey:@"(UTC-05:00) Eastern Time (US & Canada)"];
    [timeZoneDict setObject:@"US/East-Indiana" forKey:@"(UTC-05:00) Indiana (East)"];
    [timeZoneDict setObject:@"America/Lima" forKey:@"(UTC-05:00) Lima"];
    [timeZoneDict setObject:@"America/Bogota" forKey:@"(UTC-05:00) Quito"];
    [timeZoneDict setObject:@"Canada/Atlantic" forKey:@"(UTC-04:00) Atlantic Time (Canada)"];
    [timeZoneDict setObject:@"America/Caracas" forKey:@"(UTC-04:30) Caracas"];
    [timeZoneDict setObject:@"America/La_Paz" forKey:@"(UTC-04:00) La Paz"];
    [timeZoneDict setObject:@"America/Santiago" forKey:@"(UTC-04:00) Santiago"];
    [timeZoneDict setObject:@"Canada/Newfoundland" forKey:@"(UTC-03:30) Newfoundland"];
    [timeZoneDict setObject:@"America/Sao_Paulo" forKey:@"(UTC-03:00) Brasilia"];
    [timeZoneDict setObject:@"America/Argentina/Buenos_Aires" forKey:@"(UTC-03:00) Buenos Aires"];
    [timeZoneDict setObject:@"America/Argentina/Buenos_Aires" forKey:@"(UTC-03:00) Georgetown"];
    [timeZoneDict setObject:@"America/Godthab" forKey:@"(UTC-03:00) Greenland"];
    [timeZoneDict setObject:@"America/Noronha" forKey:@"(UTC-02:00) Mid-Atlantic"];
    [timeZoneDict setObject:@"Atlantic/Azores" forKey:@"(UTC-01:00) Azores"];
    [timeZoneDict setObject:@"Atlantic/Cape_Verde" forKey:@"(UTC-01:00) Cape Verde Is."];
    [timeZoneDict setObject:@"Africa/Casablanca" forKey:@"(UTC+00:00) Casablanca"];
    [timeZoneDict setObject:@"Europe/London" forKey:@"(UTC+00:00) Edinburgh"];
    [timeZoneDict setObject:@"Etc/Greenwich" forKey:@"(UTC+00:00) Greenwich Mean Time : Dublin"];
    [timeZoneDict setObject:@"Europe/Lisbon" forKey:@"(UTC+00:00) Lisbon"];
    [timeZoneDict setObject:@"Europe/London" forKey:@"(UTC+00:00) London"];
    [timeZoneDict setObject:@"Africa/Monrovia" forKey:@"(UTC+00:00) Monrovia"];
    [timeZoneDict setObject:@"UTC" forKey:@"(UTC+00:00) UTC"];
    [timeZoneDict setObject:@"Europe/Amsterdam" forKey:@"(UTC+01:00) Amsterdam"];
    [timeZoneDict setObject:@"Europe/Belgrade" forKey:@"(UTC+01:00) Belgrade"];
    [timeZoneDict setObject:@"Europe/Berlin" forKey:@"(UTC+01:00) Berlin"];
    [timeZoneDict setObject:@"Europe/Berlin" forKey:@"(UTC+01:00) Bern"];
    [timeZoneDict setObject:@"Europe/Bratislava" forKey:@"(UTC+01:00) Bratislava"];
    [timeZoneDict setObject:@"Europe/Brussels" forKey:@"(UTC+01:00) Brussels"];
    [timeZoneDict setObject:@"Europe/Budapest" forKey:@"(UTC+01:00) Budapest"];
    [timeZoneDict setObject:@"Europe/Copenhagen" forKey:@"(UTC+01:00) Copenhagen"];
    [timeZoneDict setObject:@"Europe/Ljubljana" forKey:@"(UTC+01:00) Ljubljana"];
    [timeZoneDict setObject:@"Europe/Madrid" forKey:@"(UTC+01:00) Madrid"];
    [timeZoneDict setObject:@"Europe/Paris" forKey:@"(UTC+01:00) Paris"];
    [timeZoneDict setObject:@"Europe/Prague" forKey:@"(UTC+01:00) Prague"];
    [timeZoneDict setObject:@"Europe/Rome" forKey:@"(UTC+01:00) Rome"];
    [timeZoneDict setObject:@"Europe/Sarajevo" forKey:@"(UTC+01:00) Sarajevo"];
    [timeZoneDict setObject:@"Europe/Skopje" forKey:@"(UTC+01:00) Skopje"];
    [timeZoneDict setObject:@"Europe/Stockholm" forKey:@"(UTC+01:00) Stockholm"];
    [timeZoneDict setObject:@"Europe/Vienna" forKey:@"(UTC+01:00) Vienna"];
    [timeZoneDict setObject:@"Europe/Warsaw" forKey:@"(UTC+01:00) Warsaw"];
    [timeZoneDict setObject:@"Africa/Lagos" forKey:@"(UTC+01:00) West Central Africa"];
    [timeZoneDict setObject:@"Europe/Zagreb" forKey:@"(UTC+01:00) Zagreb"];
    [timeZoneDict setObject:@"Europe/Athens" forKey:@"(UTC+02:00) Athens"];
    [timeZoneDict setObject:@"Europe/Bucharest" forKey:@"(UTC+02:00) Bucharest"];
    [timeZoneDict setObject:@"Africa/Cairo" forKey:@"(UTC+02:00) Cairo"];
    [timeZoneDict setObject:@"Africa/Harare" forKey:@"(UTC+02:00) Harare"];
    [timeZoneDict setObject:@"Europe/Helsinki" forKey:@"(UTC+02:00) Helsinki"];
    [timeZoneDict setObject:@"Europe/Istanbul" forKey:@"(UTC+02:00) Istanbul"];
    [timeZoneDict setObject:@"Asia/Jerusalem" forKey:@"(UTC+02:00) Jerusalem"];
    [timeZoneDict setObject:@"Europe/Helsinki" forKey:@"(UTC+02:00) Kyiv"];
    [timeZoneDict setObject:@"Africa/Johannesburg" forKey:@"(UTC+02:00) Pretoria"];
    [timeZoneDict setObject:@"Europe/Riga" forKey:@"(UTC+02:00) Riga"];
    [timeZoneDict setObject:@"Europe/Sofia" forKey:@"(UTC+02:00) Sofia"];
    [timeZoneDict setObject:@"Europe/Tallinn" forKey:@"(UTC+02:00) Tallinn"];
    [timeZoneDict setObject:@"Europe/Vilnius" forKey:@"(UTC+02:00) Vilnius"];
    [timeZoneDict setObject:@"Asia/Baghdad" forKey:@"(UTC+03:00) Baghdad"];
    [timeZoneDict setObject:@"Asia/Kuwait" forKey:@"(UTC+03:00) Kuwait"];
    [timeZoneDict setObject:@"Europe/Minsk" forKey:@"(UTC+03:00) Minsk"];
    [timeZoneDict setObject:@"Africa/Nairobi" forKey:@"(UTC+03:00) Nairobi"];
    [timeZoneDict setObject:@"Asia/Riyadh" forKey:@"(UTC+03:00) Riyadh"];
    [timeZoneDict setObject:@"Europe/Volgograd" forKey:@"(UTC+03:00) Volgograd"];
    [timeZoneDict setObject:@"Asia/Tehran" forKey:@"(UTC+03:30) Tehran"];
    [timeZoneDict setObject:@"Asia/Muscat" forKey:@"(UTC+04:00) Abu Dhabi"];
    [timeZoneDict setObject:@"Asia/Baku" forKey:@"(UTC+04:00) Baku"];
    [timeZoneDict setObject:@"Europe/Moscow" forKey:@"(UTC+04:00) Moscow"];
    [timeZoneDict setObject:@"Asia/Muscat" forKey:@"(UTC+04:00) Muscat"];
    [timeZoneDict setObject:@"Europe/Moscow" forKey:@"(UTC+04:00) St. Petersburg"];
    [timeZoneDict setObject:@"Asia/Tbilisi" forKey:@"(UTC+04:00) Tbilisi"];
    [timeZoneDict setObject:@"Asia/Yerevan" forKey:@"(UTC+04:00) Yerevan"];
    [timeZoneDict setObject:@"Asia/Kabul" forKey:@"(UTC+04:30) Kabul"];
    [timeZoneDict setObject:@"Asia/Karachi" forKey:@"(UTC+05:00) Islamabad"];
    [timeZoneDict setObject:@"Asia/Karachi" forKey:@"(UTC+05:00) Karachi"];
    [timeZoneDict setObject:@"Asia/Tashkent" forKey:@"(UTC+05:00) Tashkent"];
    [timeZoneDict setObject:@"Asia/Calcutta" forKey:@"(UTC+05:30) Chennai"];
    [timeZoneDict setObject:@"Asia/Kolkata" forKey:@"(UTC+05:30) Kolkata"];
    [timeZoneDict setObject:@"Asia/Calcutta" forKey:@"(UTC+05:30) Mumbai"];
    [timeZoneDict setObject:@"Asia/Calcutta" forKey:@"(UTC+05:30) New Delhi"];
    [timeZoneDict setObject:@"Asia/Calcutta" forKey:@"(UTC+05:30) Sri Jayawardenepura"];
    [timeZoneDict setObject:@"Asia/Katmandu" forKey:@"(UTC+05:45) Kathmandu"];
    [timeZoneDict setObject:@"Asia/Almaty" forKey:@"(UTC+06:00) Almaty"];
    [timeZoneDict setObject:@"Asia/Dhaka" forKey:@"(UTC+06:00) Astana"];
    [timeZoneDict setObject:@"Asia/Dhaka" forKey:@"(UTC+06:00) Dhaka"];
    [timeZoneDict setObject:@"Asia/Yekaterinburg" forKey:@"(UTC+06:00) Ekaterinburg"];
    [timeZoneDict setObject:@"Asia/Rangoon" forKey:@"(UTC+06:30) Rangoon"];
    [timeZoneDict setObject:@"Asia/Bangkok" forKey:@"(UTC+07:00) Bangkok"];
    [timeZoneDict setObject:@"Asia/Bangkok" forKey:@"(UTC+07:00) Hanoi"];
    [timeZoneDict setObject:@"Asia/Jakarta" forKey:@"(UTC+07:00) Jakarta"];
    [timeZoneDict setObject:@"Asia/Novosibirsk" forKey:@"(UTC+07:00) Novosibirsk"];
    [timeZoneDict setObject:@"Asia/Hong_Kong" forKey:@"(UTC+08:00) Beijing"];
    [timeZoneDict setObject:@"Asia/Chongqing" forKey:@"(UTC+08:00) Chongqing"];
    [timeZoneDict setObject:@"Asia/Hong_Kong" forKey:@"(UTC+08:00) Hong Kong"];
    [timeZoneDict setObject:@"Asia/Krasnoyarsk" forKey:@"(UTC+08:00) Krasnoyarsk"];
    [timeZoneDict setObject:@"Asia/Kuala_Lumpur" forKey:@"(UTC+08:00) Kuala Lumpur"];
    [timeZoneDict setObject:@"Australia/Perth" forKey:@"(UTC+08:00) Perth"];
    [timeZoneDict setObject:@"Asia/Singapore" forKey:@"(UTC+08:00) Singapore"];
    [timeZoneDict setObject:@"Asia/Taipei" forKey:@"(UTC+08:00) Taipei"];
    [timeZoneDict setObject:@"Asia/Ulan_Bator" forKey:@"(UTC+08:00) Ulaan Bataar"];
    [timeZoneDict setObject:@"Asia/Urumqi" forKey:@"(UTC+08:00) Urumqi"];
    [timeZoneDict setObject:@"Asia/Irkutsk" forKey:@"(UTC+09:00) Irkutsk"];
    [timeZoneDict setObject:@"Asia/Tokyo" forKey:@"(UTC+09:00) Osaka"];
    [timeZoneDict setObject:@"Asia/Tokyo" forKey:@"(UTC+09:00) Sapporo"];
    [timeZoneDict setObject:@"Asia/Seoul" forKey:@"(UTC+09:00) Seoul"];
    [timeZoneDict setObject:@"Asia/Tokyo" forKey:@"(UTC+09:00) Tokyo"];
    [timeZoneDict setObject:@"Australia/Adelaide" forKey:@"(UTC+09:30) Adelaide"];
    [timeZoneDict setObject:@"Australia/Darwin" forKey:@"(UTC+09:30) Darwin"];
    [timeZoneDict setObject:@"Australia/Brisbane" forKey:@"(UTC+10:00) Brisbane"];
    [timeZoneDict setObject:@"Australia/Canberra" forKey:@"(UTC+10:00) Canberra"];
    [timeZoneDict setObject:@"Pacific/Guam" forKey:@"(UTC+10:00) Guam"];
    [timeZoneDict setObject:@"Australia/Hobart" forKey:@"(UTC+10:00) Hobart"];
    [timeZoneDict setObject:@"Australia/Melbourne" forKey:@"(UTC+10:00) Melbourne"];
    [timeZoneDict setObject:@"Pacific/Port_Moresby" forKey:@"(UTC+10:00) Port Moresby"];
    [timeZoneDict setObject:@"Australia/Sydney" forKey:@"(UTC+10:00) Sydney"];
    [timeZoneDict setObject:@"Asia/Yakutsk" forKey:@"(UTC+10:00) Yakutsk"];
    [timeZoneDict setObject:@"Asia/Vladivostok" forKey:@"(UTC+11:00) Vladivostok"];
    [timeZoneDict setObject:@"Pacific/Auckland" forKey:@"(UTC+12:00) Auckland"];
    [timeZoneDict setObject:@"Pacific/Fiji" forKey:@"(UTC+12:00) Fiji"];
    [timeZoneDict setObject:@"Pacific/Kwajalein" forKey:@"(UTC+12:00) International Date Line West"];
    [timeZoneDict setObject:@"Asia/Kamchatka" forKey:@"(UTC+12:00) Kamchatka"];
    [timeZoneDict setObject:@"Asia/Magadan" forKey:@"(UTC+12:00) Magadan"];
    [timeZoneDict setObject:@"Pacific/Fiji" forKey:@"(UTC+12:00) Marshall Is."];
    [timeZoneDict setObject:@"Asia/Magadan" forKey:@"(UTC+12:00) New Caledonia"];
    [timeZoneDict setObject:@"Asia/Magadan" forKey:@"(UTC+12:00) Solomon Is."];
    [timeZoneDict setObject:@"Pacific/Auckland" forKey:@"(UTC+12:00) Wellington"];
    [timeZoneDict setObject:@"Pacific/Tongatapu" forKey:@"(UTC+13:00) Nuku'alofa"];
    
}


@end
