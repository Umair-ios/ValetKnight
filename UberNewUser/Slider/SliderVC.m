//
//  SliderVC.m
//  Employee
//
//  Created by Elluminati - macbook on 19/05/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "SliderVC.h"
#import "Constants.h"
#import "SWRevealViewController.h"
#import "PickUpVC.h"
#import "CellSlider.h"
#import "HistoryVC.h"
#import "AboutVC.h"
#import "PaymentVC.h"
#import "ProfileVC.h"
#import "PromotionsVC.h"
#import "ContactUsVC.h"
#import "UIView+Utils.h"
#import "UIImageView+Download.h"


@interface SliderVC ()
{
    NSMutableArray *arrListName,*arrIdentifire;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSString *strContent;
}

@end

@implementation SliderVC

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
    arrSlider=[[NSMutableArray alloc]initWithObjects:@"PROFILE",@"HISTORY",@"PAYMENTS",nil ];//@"Promotions",@"Logout", nil];
    arrImages=[[NSMutableArray alloc]initWithObjects:@"nav_profile",@"ub__nav_history",@"nav_payment",nil];//@"icon-29.png",@"icon-29.png",@"ub__nav_promotions.png",@"ub__nav_logout.png",nil];
    self.tblMenu.backgroundView=nil;
    self.tblMenu.backgroundColor=[UIColor clearColor];
    [self.imgProfilePic applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];
    
    [self.imgProfilePic downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    
    self.lblName.font=[UberStyleGuide fontRegular:18.0f];
    
    self.lblName.text=[NSString stringWithFormat:@"%@ %@",[dictInfo valueForKey:@"first_name"],[dictInfo valueForKey:@"last_name"]];
    
    arrIdentifire=[[NSMutableArray alloc]initWithObjects:SEGUE_PROFILE,SEGUE_TO_HISTORY,SEGUE_PAYMENT, nil];
    
    NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
    NSMutableArray *arrImg=[[NSMutableArray alloc]init];
    
//    for (int i=0; i<arrPage.count; i++)
//    {
//        NSMutableDictionary *temp1=[arrPage objectAtIndex:i];
//        [arrTemp addObject:[temp1 valueForKey:@"title"]];
//        [arrImg addObject:@"nav_about"];
//    }
    
    [arrSlider addObjectsFromArray:arrTemp];
    [arrIdentifire addObjectsFromArray:arrTemp];
    [arrIdentifire addObject:SEGUE_TO_REFERRAL_CODE];
    
    [arrImages addObjectsFromArray:arrImg];
    
    [arrSlider addObject:@"PROMOTIONS"];
    [arrImages addObject:@"nav_promotions"];

    [arrSlider addObject:@"FREE RIDES"];
    [arrImages addObject:@"nav_share"];

    [arrSlider addObject:@"LOG OUT"];
    [arrImages addObject:@"ub__nav_logout"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    
    frontVC=[nav.childViewControllers objectAtIndex:0];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];
    
    [self.imgProfilePic downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    
    self.lblName.font=[UberStyleGuide fontRegular:18.0f];
    self.lblName.text=[NSString stringWithFormat:@"%@ %@",[dictInfo valueForKey:@"first_name"],[dictInfo valueForKey:@"last_name"]];
}

#pragma mark -
#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrSlider count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellSlider *cell=(CellSlider *)[tableView dequeueReusableCellWithIdentifier:@"CellSlider"];
    if (cell==nil) {
        cell=[[CellSlider alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellSlider"];
    }
    cell.lblName.text=[arrSlider objectAtIndex:indexPath.row];
    cell.imgIcon.image=[UIImage imageNamed:[arrImages objectAtIndex:indexPath.row]];
    
    
    //[cell setCellData:[arrSlider objectAtIndex:indexPath.row] withParent:self];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[arrSlider objectAtIndex:indexPath.row]isEqualToString:@"LOG OUT"])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Log Out" message:@"Are Sure You Want to Log Out?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag=100;
        [alert show];
        
        return;
    }
 /*
    if ((indexPath.row >2)&&(indexPath.row<(arrSlider.count-3)))
    {
        [self.revealViewController rightRevealToggle:self];
        
        UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
        
        self.ViewObj=(PickUpVC *)[nav.childViewControllers objectAtIndex:0];
        
        NSDictionary *dictTemp=[arrPage objectAtIndex:indexPath.row-3];
        strContent=[dictTemp valueForKey:@"content"];
        
        [self.ViewObj performSegueWithIdentifier:@"contactus" sender:dictTemp];
        return;
    }
   */
    
    [self.revealViewController rightRevealToggle:self];
    
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    
    self.ViewObj=(PickUpVC *)[nav.childViewControllers objectAtIndex:0];
    
    if(self.ViewObj!=nil) {
        NSDictionary *dictTemp;
        
        if ([[arrSlider objectAtIndex:indexPath.row] isEqualToString:@"FREE RIDES"]) {
            dictTemp = [[NSDictionary alloc] initWithObjectsAndKeys:@"FREE RIDES",@"title",[NSString stringWithFormat:@"%@",[arrImages objectAtIndex:indexPath.row]],@"titleImg", nil];
            
            [self.ViewObj performSegueWithIdentifier:SEGUE_TO_REFERRAL_CODE sender:dictTemp];
        }
        else if ([[arrSlider objectAtIndex:indexPath.row] isEqualToString:@"PROMOTIONS"]) {
            dictTemp = [[NSDictionary alloc] initWithObjectsAndKeys:@"PROMOTIONS",@"title",[NSString stringWithFormat:@"%@",[arrImages objectAtIndex:indexPath.row]],@"titleImg", nil];

            [self.ViewObj performSegueWithIdentifier:SEGUE_TO_REFERRAL_CODE sender:dictTemp];
        }
        else {
            [self.ViewObj goToSetting:[arrIdentifire objectAtIndex:indexPath.row]];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //UIView *v=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
    //v.backgroundColor=[UIColor clearColor];
    return nil;
}

- (void)onClickProfile:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PROFILE sender:frontVC];
    }
}

- (void)onClickPayment:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PAYMENT sender:frontVC];
    }
}

- (void)onClickPromotions:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PROMOTIONS sender:frontVC];
    }
}

- (void)onClickShare:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_SHARE sender:frontVC];
    }
}

- (void)onClickSupport:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_SUPPORT sender:frontVC];
    }
}

- (void)onClickAbout:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_ABOUT sender:frontVC];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            [pref synchronize];
            [pref removeObjectForKey:PREF_USER_TOKEN];
            [pref removeObjectForKey:PREF_REQ_ID];
            [pref removeObjectForKey:PREF_IS_LOGOUT];
            [pref removeObjectForKey:PREF_USER_ID];
            [pref removeObjectForKey:PREF_IS_LOGIN];
            [pref removeObjectForKey:PREF_PAYMENT_METHOD];
            [pref removeObjectForKey:PREF_REFERRAL_CODE];
            
            [APPDELEGATE showToastMessage:@"You have been Logged out successfully"];

            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
