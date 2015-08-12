//
//  PickUpVC.m
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "PickUpVC.h"
#import "SWRevealViewController.h"
#import "AFNHelper.h"
#import "AboutVC.h"
#import "ContactUsVC.h"
#import "ProviderDetailsVC.h"
#import "CarTypeCell.h"
#import "UIImageView+Download.h"
#import "CarTypeDataModal.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "UberStyleGuide.h"
#import "OptionsVC.h"
#import "Helper.h"
#import "DriverList.h"
#import "ReferralCodeVC.h"
#import "SearchViewController.h"
#import <GoogleMaps/GoogleMaps.h>


@interface PickUpVC () <SWRevealViewControllerDelegate>
{
    NSString *strForUserId,*strForUserToken,*strForLatitude,*strForLongitude,*strForRequestID,*strForDriverLatitude,*strForDriverLongitude,*strForTypeid,*strForCurLatitude,*strForCurLongitude,*strForDestLat,*strForDestLong,*strPaymentMethod,*strForETAtime;
    NSInteger typeID;
    NSMutableArray *arrForInformation, *arrForApplicationType, *arrForAddress, *driversArr, *newMarkersArr, *addedMarkersArr;
    BOOL isCOD, isCard, isPaypal, isPromo;
    GMSMapView *mapView_;
    UIButton *btn;
}

@property (weak, nonatomic) IBOutlet UILabel *carTypeLbl;
@property (weak, nonatomic) IBOutlet UIButton *btnFareEstimate;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyPromo;
@property (weak, nonatomic) IBOutlet UIView *applyPromoView;
@property (weak, nonatomic) IBOutlet UITextField *applyPromoTxt;
@property (weak, nonatomic) IBOutlet UIButton *etaBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnPaymentMethod;
@property (weak, nonatomic) IBOutlet UILabel *basePriceLbl;
@property (weak, nonatomic) IBOutlet UILabel *perKmPriceLbl;
@property (weak, nonatomic) IBOutlet UILabel *perMinPriceLbl;
@property (weak, nonatomic) IBOutlet UIView *fareCardView;
@property (weak, nonatomic) IBOutlet UIButton *carCategoryBtn;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIView *destinationView;
@property (weak, nonatomic) IBOutlet UITextField *destLocationTxt;
@property (weak, nonatomic) IBOutlet UIButton *btncloseDestination;
@property (weak, nonatomic) IBOutlet UIButton *btnAddDestination;
@property (weak, nonatomic) IBOutlet UIImageView *pickmeBg;
@property (weak, nonatomic) IBOutlet UILabel *promoDescriptionLbl;
@property (weak, nonatomic) IBOutlet UILabel *promoHeaderLbl;
@property (weak, nonatomic) IBOutlet UIButton *promoApplyBtn;


@end

@implementation PickUpVC

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
    
    self.revealViewController.delegate = self;
    
    strForTypeid=@"0";
    self.btnCancel.hidden=YES;
    arrForAddress=[[NSMutableArray alloc]init];
    self.tableView.hidden=YES;
    [self setTimerToCheckDriverStatus];
    [self customFont];
    [self updateLocationManagerr];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:@"0" forKey:PREF_IS_OPTIONS];
    [pref removeObjectForKey:PREF_FULL_ADDRESS];
    
    CLLocationCoordinate2D coordinate = [self getLocation];
    strForCurLatitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    strForCurLongitude= [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    UITapGestureRecognizer *tapRemoveKeyBoard = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeKeyBoard)];
    [tapRemoveKeyBoard setDelegate:self];
    [tapRemoveKeyBoard setNumberOfTapsRequired:1];
    [self.applyPromoView addGestureRecognizer:tapRemoveKeyBoard];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForCurLatitude doubleValue] longitude:[strForCurLongitude doubleValue] zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.viewGoogleMap.frame.size.width, self.viewGoogleMap.frame.size.height) camera:camera];
    mapView_.myLocationEnabled = NO;
    
    [self.viewGoogleMap addSubview:mapView_];
    mapView_.delegate=self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    addedMarkersArr = [[NSMutableArray alloc]initWithCapacity:0];
    arrForApplicationType=[[NSMutableArray alloc]initWithCapacity:0];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_PAYMENT_METHOD];
    
    self.navigationController.navigationBarHidden=NO;
    
    self.viewForMarker.center=CGPointMake(self.viewGoogleMap.frame.size.width/2, self.viewGoogleMap.frame.size.height/2-40);
    [self.viewGoogleMap bringSubviewToFront:self.btnFareEstimate];
    [self.viewGoogleMap bringSubviewToFront:self.btnApplyPromo];
    [self getAllApplicationType];
    [super setNavBarTitle:TITLE_PICKUP];
    
    [self hideOptions];
    [self customSetup];
    [self checkForAppStatus];
    [self getPagesData];
    [self getAllPaymentOptions];
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        [btn removeFromSuperview];
    } else {
        btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [btn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:btn];
        [self.view bringSubviewToFront:btn];
    }
}

/*
 - (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
 {
 if(position == FrontViewPositionLeft) {
 btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
 [btn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
 [btn setBackgroundColor:[UIColor clearColor]];
 [self.view addSubview:btn];
 [self.view bringSubviewToFront:btn];
 //self.view.userInteractionEnabled = YES;
 } else {
 [btn removeFromSuperview];
 //self.view.userInteractionEnabled = NO;
 }
 }
 */

-(void)hideOptions {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictAdd = [[NSMutableDictionary alloc]init];
    dictAdd = [pref objectForKey:PREF_FULL_ADDRESS];
    
    if ([[pref objectForKey:PREF_IS_OPTIONS] isEqual:@"1"]) {
        [self.btnAddDestination setHidden:YES];
        [self.btnSelService setHidden:YES];
        [self.destinationView setHidden:NO];
        [self.optionsView setHidden:NO];
        if ([[dictAdd valueForKey:PREF_ADDRESS_TYPE] isEqualToString:PREF_DEST_ADD]) {
            [self.destLocationTxt setText:[dictAdd valueForKey:@"address"]];
            [self getLocationFromString:self.destLocationTxt.text forTextField:self.destLocationTxt];
        }
        else if ([[dictAdd valueForKey:PREF_ADDRESS_TYPE] isEqualToString:PREF_SOURCE_ADD]){
            [self.txtAddress setText:[dictAdd valueForKey:@"address"]];
            [self getLocationFromString:self.txtAddress.text forTextField:self.txtAddress];
        }
        else {
            [self.destLocationTxt setText:[pref objectForKey:@"destLocationText"]];
            if ([self.destLocationTxt.text isEqualToString:@""]) {
                [self getLocationFromString:self.destLocationTxt.text forTextField:self.destLocationTxt];
            }
        }
    }
    else {
        [self.btnPickMeUp setHidden:NO];
        [self.pickmeBg setHidden:NO];
        [self.btnAddDestination setHidden:YES];
        [self.btnSelService setHidden:NO];
        [self.destinationView setHidden:YES];
        [self.optionsView setHidden:YES];
        
        if ([[dictAdd valueForKey:PREF_ADDRESS_TYPE] isEqualToString:PREF_DEST_ADD]) {
            [self.destLocationTxt setText:[dictAdd valueForKey:@"address"]];
            [self getLocationFromString:self.destLocationTxt.text forTextField:self.destLocationTxt];
        }
        else if ([[dictAdd valueForKey:PREF_ADDRESS_TYPE] isEqualToString:PREF_SOURCE_ADD]){
            [self.txtAddress setText:[dictAdd valueForKey:@"address"]];
            [self getLocationFromString:self.txtAddress.text forTextField:self.txtAddress];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:PREF_FULL_ADDRESS];
}

-(void)deactivatePickmeBtn {
    if (addedMarkersArr == nil || [addedMarkersArr count]==0) {
        [self.btnPickMeUp setAlpha:0.7f];
        [self.pickmeBg setAlpha:0.7f];
        [self.btnPickMeUp setUserInteractionEnabled:NO];
    }
    else {
        [self.btnPickMeUp setAlpha:1.0f];
        [self.pickmeBg setAlpha:1.0f];
        [self.btnPickMeUp setUserInteractionEnabled:YES];
    }
}

-(void)removeKeyBoard {
    
    if ([self.applyPromoTxt isFirstResponder]) {
        [self checkPromoCode];
        [self.txtAddress setUserInteractionEnabled:NO];
        [self.applyPromoTxt resignFirstResponder];
    }
    else {
        [self.txtAddress setUserInteractionEnabled:YES];
        [self.applyPromoView removeFromSuperview];
    }
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

#pragma mark-
#pragma mark-

-(void)customFont
{
    self.txtAddress.font=[UberStyleGuide fontRegular];
    self.destLocationTxt.font=[UberStyleGuide fontRegular];
    
    [self.destinationView setBackgroundColor:[Helper getColorFromHexString:@"#f8f8f8" :0.9f]];
    self.btnCancel=[APPDELEGATE setBoldFontDiscriptor:self.btnCancel];
    self.btnPickMeUp=[APPDELEGATE setBoldFontDiscriptor:self.btnPickMeUp];
    self.btnSelService=[APPDELEGATE setBoldFontDiscriptor:self.btnSelService];
    
    [[self.btncloseDestination layer]setCornerRadius:self.btncloseDestination.frame.size.height/2];
    [[self.btnAddDestination layer]setCornerRadius:self.btnAddDestination.frame.size.height/2];
}

#pragma mark -
#pragma mark - Location Delegate

-(CLLocationCoordinate2D) getLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    return coordinate;
}

-(void)updateLocationManagerr
{
    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [locationManager requestWhenInUseAuthorization];
        //[locationManager requestAlwaysAuthorization];
    }
#endif
    
    [locationManager startUpdatingLocation];
    
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    strForCurLatitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    strForCurLongitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    ////NSLog(@"didFailWithError: %@", error);
}

#pragma mark-
#pragma mark- Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}


#pragma mark- Google Map Delegate

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    strForLatitude=[NSString stringWithFormat:@"%f",position.target.latitude];
    strForLongitude=[NSString stringWithFormat:@"%f",position.target.longitude];
    
    [self getNearbyProvidersForLat:strForLatitude andLong:strForLongitude];
    [self getAddress];
}

-(void)getAddress
{
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[strForLatitude floatValue], [strForLongitude floatValue], [strForLatitude floatValue], [strForLongitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    
    NSDictionary *getRoutes = [JSON valueForKey:@"routes"];
    NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
    NSArray *getAddress = [getLegs valueForKey:@"end_address"];
    if (getAddress.count!=0)
    {
        self.txtAddress.text=[[getAddress objectAtIndex:0]objectAtIndex:0];
    }
}

#pragma mark -
#pragma mark - Mapview Delegate

-(void)showMapCurrentLocatinn
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:14];
    [mapView_ animateWithCameraUpdate:updatedCamera];
    
    [self getAddress];
    
    //[self getNearbyProvidersForLat:[NSString stringWithFormat:@"%f",coordinate.latitude] andLong:[NSString stringWithFormat:@"%f",coordinate.longitude]];
}


#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:SEGUE_ABOUT]) {
        AboutVC *obj=[segue destinationViewController];
        obj.arrInformation=arrForInformation;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_ACCEPT]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PREF_IS_OPTIONS];
        
        ProviderDetailsVC *obj=[segue destinationViewController];
        obj.strForLatitude=strForLatitude;
        obj.strForLongitude=strForLongitude;
        obj.strForWalkStatedLatitude=strForDriverLatitude;
        obj.strForWalkStatedLongitude=strForDriverLongitude;
        obj.strForDropLatitude = strForDestLat;
        obj.strForDropLongitude = strForDestLong;
        
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_CONTACT_US]) {
        ContactUsVC *obj=[segue destinationViewController];
        obj.dictContent=sender;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_SHOW_FARE_ESTIMATOR]) {
        OptionsVC *options = [segue destinationViewController];
        CarTypeDataModal *obj = [[CarTypeDataModal alloc]init];

        if ([arrForApplicationType count] > 0) {
            obj = [arrForApplicationType objectAtIndex:typeID];
        }
        else {
            obj = [arrForApplicationType objectAtIndex:0];
        }
        options.strForCarType = obj.name;
        options.strForSourceAdd = self.txtAddress.text;
        options.strForDestAdd = self.destLocationTxt.text;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_REFERRAL_CODE]) {
        ReferralCodeVC *refObj=[segue destinationViewController];
        refObj.dictContent = sender;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_ADDRESS_SEARCH]) {
        SearchViewController *refObj=[segue destinationViewController];
        
        NSString *txtFieldName;
        UITextField *txtField = sender;
        if ([txtField isEqual:self.txtAddress]) {
            txtFieldName = PREF_SOURCE_ADD;
        }
        else if ([txtField isEqual:self.destLocationTxt]) {
            txtFieldName = PREF_DEST_ADD;
        }
        refObj.fromTextField = txtFieldName;
    }
}

-(void)goToSetting:(NSString *)str
{
    [self performSegueWithIdentifier:str sender:self];
}

#pragma mark -
#pragma mark - UIButton Action

- (IBAction)pickMeUpBtnPressed:(id)sender {
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:@"1" forKey:PREF_IS_OPTIONS];
    
    NSString *carType;
    if ([arrForApplicationType count] > 0) {
        CarTypeDataModal *obj = [[CarTypeDataModal alloc]init];
        obj = [arrForApplicationType objectAtIndex:typeID];
        carType = obj.name;
    }
    else {
        carType = [[NSUserDefaults standardUserDefaults]objectForKey:@"defaultCarType"];
    }
    
    [self.carCategoryBtn setTitle:carType forState:UIControlStateNormal]; //#fb9d3e
    
    self.optionsView.frame = CGRectMake(0, self.view.bounds.size.height-self.optionsView.frame.size.height, self.view.bounds.size.height, self.optionsView.frame.size.height);
    [self.optionsView setBackgroundColor:[Helper getColorFromHexString:@"#fb9d3e" :0.4f]];
    [self.view addSubview:self.optionsView];
    
    if ([self.btnSelService isHidden]) {
        [self.btnAddDestination setHidden:NO];
        [self animateViewHeight:self.btnSelService withAnimationType:kCATransitionFromTop];
        [self animateViewHeight:self.optionsView withAnimationType:kCATransitionFromBottom];
        [self performSelector:@selector(addDestinationEvent:) withObject:self];
        [self animateViewHeight:self.pickmeBg withAnimationType:kCATransitionFromBottom];
        [self animateViewHeight:self.btnPickMeUp withAnimationType:kCATransitionFromBottom];
    }
    else {
        [self.btnAddDestination setHidden:NO];
        [self animateViewHeight:self.btnSelService withAnimationType:kCATransitionFromBottom];
        [self animateViewHeight:self.optionsView withAnimationType:kCATransitionFromTop];
        [self performSelector:@selector(addDestinationEvent:) withObject:self];
        [self animateViewHeight:self.pickmeBg withAnimationType:kCATransitionFromTop];
        [self animateViewHeight:self.btnPickMeUp withAnimationType:kCATransitionFromTop];
    }
    
}

-(void)createRequest {
    if([CLLocationManager locationServicesEnabled])
    {
        if ([strForTypeid isEqualToString:@"0"]||strForTypeid==nil)
        {
            strForTypeid=@"1";
        }
        if(![strForTypeid isEqualToString:@"0"])
        {
            if(((strForLatitude==nil)&&(strForLongitude==nil))
               ||(([strForLongitude doubleValue]==0.00)&&([strForLatitude doubleValue]==0)))
            {
                [APPDELEGATE showToastMessage:NSLocalizedString(@"NOT_VALID_LOCATION", nil)];
            }
            else
            {
                if([[AppDelegate sharedAppDelegate]connected])
                {
                    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil) andAlpha:0.85f];
                    
                    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                    strForUserId=[pref objectForKey:PREF_USER_ID];
                    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
                    strPaymentMethod=[pref objectForKey:PREF_PAYMENT_METHOD];
                    if (strPaymentMethod == nil) {
                        if (isCard) {
                            strPaymentMethod = @"0";
                        }
                        else if (isCOD) {
                            strPaymentMethod = @"1";
                        }
                        else if (isPaypal) {
                            strPaymentMethod = @"2";
                        }
                    }
                    
                    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                    [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
                    [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
                    [dictParam setValue:strForDestLat forKey:PARAM_DEST_LATITUDE];
                    [dictParam setValue:strForDestLong forKey:PARAM_DEST_LONGITUDE];
                    //[dictParam setValue:@"22.3023117"  forKey:PARAM_LATITUDE];
                    //[dictParam setValue:@"70.7969645"  forKey:PARAM_LONGITUDE];
                    //[dictParam setValue:@"1" forKey:PARAM_DISTANCE];
                    [dictParam setValue:strForUserId forKey:PARAM_ID];
                    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
                    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
                    [dictParam setValue:strPaymentMethod forKey:PARAM_PAYMENT_TYPE];
                    [dictParam setValue:self.applyPromoTxt.text forKey:PARAM_PROMO];
                    
                    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                    [afn getDataFromPath:FILE_CREATE_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
                     {
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         if (response)
                         {
                             if([[response valueForKey:@"success"]boolValue])
                             {
                                 ////NSLog(@"CREATE REQ -> %@",response);
                                 if([[response valueForKey:@"success"]boolValue])
                                 {
                                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                                     
                                     strForRequestID=[response valueForKey:PARAM_REQUEST_ID];
                                     [pref setObject:strForRequestID forKey:PREF_REQ_ID];
                                     [self setTimerToCheckDriverStatus];
                                     
                                     [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"COTACCTING_SERVICE_PROVIDER", nil) andAlpha:0.85f];
                                     self.btnCancel.hidden=NO;
                                     [APPDELEGATE.window addSubview:self.btnCancel];
                                     [APPDELEGATE.window bringSubviewToFront:self.btnCancel];
                                 }
                             }
                             else {
                                 NSString *btnOption;
                                 if (isCard) {
                                     btnOption = @"Pay Now";
                                 }
                                 else {
                                     btnOption = @"Add Card";
                                 }
                                 
                                 UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@. Pay now to take rides",[response valueForKey:@"error"]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:btnOption, nil];
                                 popup.tag = 2;
                                 
                                 [popup showInView:[UIApplication sharedApplication].keyWindow];
                             }
                         }
                         
                         
                     }];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [self hideOptions];
                    [alert show];
                }
            }
            
        }
        else
            [APPDELEGATE showToastMessage:NSLocalizedString(@"SELECT_TYPE", nil)];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}

- (IBAction)cancelReqBtnPressed:(id)sender
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([[AppDelegate sharedAppDelegate]connected])
        {
            [[AppDelegate sharedAppDelegate]hideLoadingView];
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CANCLEING", nil)];
            
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            strForUserId=[pref objectForKey:PREF_USER_ID];
            strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
            NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            [dictParam setValue:strReqId forKey:PARAM_REQUEST_ID];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         [timerForCheckReqStatus invalidate];
                         timerForCheckReqStatus=nil;
                         NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
                         [pref removeObjectForKey:PREF_REQ_ID];
                         
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         [self.btnCancel setHidden:YES];
                         [self hideOptions];
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
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
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}

- (IBAction)myLocationPressed:(id)sender
{
    if ([CLLocationManager locationServicesEnabled])
    {
        CLLocationCoordinate2D coor;
        coor.latitude=[strForCurLatitude doubleValue];
        coor.longitude=[strForCurLongitude doubleValue];
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:14];
        [mapView_ animateWithCameraUpdate:updatedCamera];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
}

- (IBAction)selectServiceBtnPressed:(id)sender
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    [self.collectionView reloadData];
    
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        float closeY=(iOSDeviceScreenSize.height-self.btnSelService.frame.size.height);
        
        float openY=closeY-(self.bottomView.frame.size.height-self.btnSelService.frame.size.height);
        if (self.bottomView.frame.origin.y==closeY)
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomView.frame=CGRectMake(0, openY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                
            } completion:^(BOOL finished)
             {
             }];
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomView.frame=CGRectMake(0, closeY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                
            } completion:^(BOOL finished)
             {
             }];
        }
        
    }
    
    
}

#pragma mark -
#pragma mark - Custom WS Methods

-(void)getAllApplicationType
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_APPLICATION_TYPE withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSMutableArray *arr=[[NSMutableArray alloc]init];
                     [arr addObjectsFromArray:[response valueForKey:@"types"]];
                     for(NSMutableDictionary *dict in arr)
                     {
                         CarTypeDataModal *obj=[[CarTypeDataModal alloc]init];
                         obj.id_=[dict valueForKey:@"id"];
                         obj.name=[dict valueForKey:@"name"];
                         if ([obj.id_ isEqual:@"1"]) {
                             [[NSUserDefaults standardUserDefaults]setObject:[dict valueForKey:@"name"] forKey:@"defaultCarType"];
                         }
                         obj.icon=[dict valueForKey:@"icon"];
                         obj.is_default=[dict valueForKey:@"is_default"];
                         obj.price_per_unit_time=[dict valueForKey:@"price_per_unit_time"];
                         obj.price_per_unit_distance=[dict valueForKey:@"price_per_unit_distance"];
                         obj.base_price=[dict valueForKey:@"base_price"];
                         if ([obj.id_ isEqual:@"1"]) {
                             obj.isSelected=YES;
                         }
                         else {
                             obj.isSelected=NO;
                         }
                         [arrForApplicationType addObject:obj];
                         
                         [[NSUserDefaults standardUserDefaults]setObject:[dict valueForKey:@"currency"] forKey:@"defaultCurrency"];
                     }
//                     [self.collectionView remove]
                     [self.collectionView reloadData];
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

-(void)setTimerToCheckDriverStatus
{
    if (timerForCheckReqStatus) {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
    }
    
    timerForCheckReqStatus = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForRequestStatus) userInfo:nil repeats:YES];
}
-(void)checkForAppStatus
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
    
    if(strReqId!=nil)
    {
        [self checkForRequestStatus];
    }
    else
    {
        [self checkRequestInProgress];
    }
}

-(void)checkForRequestStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 ////NSLog(@"CHECK REQ - %@",response);
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     ////NSLog(@"GET REQ--->%@",response);
                     NSString *strCheck=[response valueForKey:@"walker"];
                     
                     if(strCheck)
                     {
                         [self.btnCancel setHidden:YES];
                         
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                         strForDriverLatitude=[dictWalker valueForKey:@"latitude"];
                         strForDriverLongitude=[dictWalker valueForKey:@"longitude"];
                         strForDestLat=[dictWalker valueForKey:@"d_latitude"];
                         strForDestLong=[dictWalker valueForKey:@"d_longitude"];
                         
                         if ([[response valueForKey:@"is_walker_rated"]integerValue]==1)
                         {
                             [pref removeObjectForKey:PREF_REQ_ID];
                             return ;
                         }
                         
                         ProviderDetailsVC *vcFeed = nil;
                         for (int i=0; i<self.navigationController.viewControllers.count; i++)
                         {
                             UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                             if ([vc isKindOfClass:[ProviderDetailsVC class]])
                             {
                                 vcFeed = (ProviderDetailsVC *)vc;
                             }
                         }
                         if (vcFeed==nil)
                         {
                             [timerForCheckReqStatus invalidate];
                             timerForCheckReqStatus=nil;
                             [self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];
                         }else
                         {
                             [self.navigationController popToViewController:vcFeed animated:NO];
                         }
                     }
                     
                     if([[response valueForKey:@"confirmed_walker"] intValue]==0 && [[response valueForKey:@"status"] intValue]==0)
                     {
                         if ([[response valueForKey:@"error_code"] intValue] == 484) {
                             [[AppDelegate sharedAppDelegate]hideLoadingView];
                             [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"SEARCHING_PROVIDERS", nil) andAlpha:0.85f];
                             
                             self.btnCancel.hidden=NO;
                             [APPDELEGATE.window addSubview:self.btnCancel];
                             [APPDELEGATE.window bringSubviewToFront:self.btnCancel];
                         }
                         else {
                             [[AppDelegate sharedAppDelegate]hideLoadingView];
                             [timerForCheckReqStatus invalidate];
                             timerForCheckReqStatus=nil;
                             NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                             [pref removeObjectForKey:PREF_REQ_ID];
                             [pref removeObjectForKey:PREF_PAYMENT_METHOD];
                             
                             [self hideOptions];
                             [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                             self.btnCancel.hidden=YES;
                             [self setTimerToCheckDriverStatus];
                             [APPDELEGATE hideLoadingView];
                         }
                     }
                 }
                 else if([[response valueForKey:@"current_walker"] intValue]==0 && [[response valueForKey:@"status"] intValue]==1){
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     [timerForCheckReqStatus invalidate];
                     timerForCheckReqStatus=nil;
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     [pref removeObjectForKey:PREF_REQ_ID];
                     
                     [self hideOptions];
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                     self.btnCancel.hidden=YES;
                     [self checkForAppStatus];
                     [APPDELEGATE hideLoadingView];
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

-(void)checkRequestInProgress
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_REQUEST_PROGRESS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     [pref setObject:[response valueForKey:@"request_id"] forKey:PREF_REQ_ID];
                     [pref synchronize];
                     [self checkForRequestStatus];
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

-(void)getPagesData
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@",FILE_PAGE,PARAM_ID,strForUserId];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             ////NSLog(@"Respond to Request= %@",response);
             [APPDELEGATE hideLoadingView];
             
             if (response)
             {
                 arrPage=[response valueForKey:@"informations"];
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     //   [APPDELEGATE showToastMessage:@"Requset Accepted"];
                 }
             }
             
         }];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrForApplicationType.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CarTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cartype" forIndexPath:indexPath];
    
    NSDictionary *dictType=[arrForApplicationType objectAtIndex:indexPath.row];
    if (strForTypeid==nil || [strForTypeid isEqualToString:@"0"])
    {
        if ([[dictType valueForKey:@"is_default"]intValue]==1)
        {
            for(CarTypeDataModal *obj in arrForApplicationType)
            {
                obj.isSelected = NO;
            }
            CarTypeDataModal *obj=[arrForApplicationType objectAtIndex:indexPath.row];
            obj.isSelected = YES;
            strForTypeid=[NSString stringWithFormat:@"%@",obj.id_];
        }
    }
    
    [cell setCellData:[arrForApplicationType objectAtIndex:indexPath.row]];
    
    //  cell.imgType.layer.masksToBounds = YES;
    //  cell.imgType.layer.opaque = NO;
    //  cell.imgType.layer.cornerRadius=18;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    for(CarTypeDataModal *obj in arrForApplicationType) {
        obj.isSelected = NO;
    }
    CarTypeDataModal *obj=[arrForApplicationType objectAtIndex:indexPath.row];
    obj.isSelected = YES;
    strForTypeid=[NSString stringWithFormat:@"%@",obj.id_];
    typeID = indexPath.row;
    
    [self performSelector:@selector(selectServiceBtnPressed:) withObject:self];
    
    [self.etaBtn setTitle:@"No Drivers" forState:UIControlStateNormal];
    [addedMarkersArr removeAllObjects];
    [self deactivatePickmeBtn];
    [mapView_ clear];
    [self getNearbyProvidersForLat:strForLatitude andLong:strForLongitude];
    
    [self.collectionView reloadData];
}



#pragma mark
#pragma mark - UITextfield Delegate


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //NSString *strFullText=[NSString stringWithFormat:@"%@%@",textField.text,string];
    
    if(self.txtAddress==textField)
    {
        /*
         if([string isEqualToString:@""])
         {
         isSearching=NO;
         self.tableForCountry.frame=tempCountryRect;
         
         [self.tableForCountry reloadData];
         }
         else
         {
         isSearching=YES;
         self.tableForCountry.hidden=NO;
         [arrForFilteredCountry removeAllObjects];
         for (NSMutableDictionary *dict in self.arrForCountry) {
         NSString *tempStr=[dict valueForKey:@"country_name"];
         NSComparisonResult result = [tempStr compare:strFullText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [strFullText length])];
         if (result == NSOrderedSame) {
         [arrForFilteredCountry addObject:dict];
         }
         }*/
        
        
        //[self getLocationFromString:strFullText];
        
        if(arrForAddress.count==1)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x,86+134, self.tableView.frame.size.width, 44);
        else if(arrForAddress.count==2)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x, 86+78, self.tableView.frame.size.width, 88);
        else if(arrForAddress.count==3)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x, 86+34, self.tableView.frame.size.width, 132);
        else if(arrForAddress.count==0)
            self.tableView.hidden=YES;
        
        [self.tableView reloadData];
        
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (![textField isEqual:self.applyPromoTxt]) {
        textField.text=@"";
        [self performSegueWithIdentifier:@"segueForAddressSearch" sender:textField];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //    if ([textField isEqual:self.txtAddress]) {
    //        [self getLocationFromString:textField.text forTextField:textField];
    //    }
    //    else if ([textField isEqual:self.destLocationTxt]) {
    //        [self getLocationFromString:textField.text forTextField:textField];
    //    }
    if (![textField isEqual:self.applyPromoTxt]) {
        [self getLocationFromString:textField.text forTextField:textField];
    }
    else {
        [self checkPromoCode];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void)getLocationFromString:(NSString *)str forTextField:(UITextField *)textField
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    if ([[AppDelegate sharedAppDelegate]connected]) {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getAddressFromGooglewithParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if(response)
             {
                 NSArray *arrAddress=[response valueForKey:@"results"];
                 
                 if ([arrAddress count] > 0)
                 {
                     textField.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     
                     if ([textField isEqual:self.txtAddress]) {
                         strForLatitude=[dictLocation valueForKey:@"lat"];
                         strForLongitude=[dictLocation valueForKey:@"lng"];
                         CLLocationCoordinate2D coor;
                         coor.latitude=[strForLatitude doubleValue];
                         coor.longitude=[strForLongitude doubleValue];
                         
                         GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:14];
                         [mapView_ animateWithCameraUpdate:updatedCamera];
                     }
                     else if ([textField isEqual:self.destLocationTxt]) {
                         strForDestLat = [dictLocation valueForKey:@"lat"];
                         strForDestLong = [dictLocation valueForKey:@"lng"];
                     }
                 }
             }
         }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)fareEstimate:(id)sender {
    [timerForCheckReqStatus invalidate];
    timerForCheckReqStatus=nil;
    [self performSegueWithIdentifier:@"showFareEstimator" sender:self];
}

- (IBAction)showPromoView:(id)sender {
    self.applyPromoView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    self.applyPromoView.backgroundColor = [Helper getColorFromHexString:@"#000000" :0.7f];
    
    [self.view addSubview:self.applyPromoView];
    [self.view bringSubviewToFront:self.applyPromoView];
    
    [self.txtAddress setUserInteractionEnabled:NO];
}

-(void)checkPromoCode {
    if ([self.applyPromoTxt.text isEqual:@""]) {
        [APPDELEGATE showToastMessage:@"Add a Promo code to avail offers"];
    }
    else {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_CHECK_PROMO,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_PROMO,self.applyPromoTxt.text];
        
        if ([[AppDelegate sharedAppDelegate]connected]) {
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
            [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error) {
                if (response) {
                    if ([[response valueForKey:@"success"]boolValue] == true) {
                        ////NSLog(@"CHECK PROMO -> %@",response);
                        
                        //[self.txtAddress setUserInteractionEnabled:YES];
                        [self.promoDescriptionLbl setText:[NSString stringWithFormat:@"You get %@ off on your current ride. Cheers !!!",[response objectForKey:@"discount"]]];
                        [self.promoHeaderLbl setText:@"PROMO ADDED"];
                        [self.promoApplyBtn setTitle:@"EDIT" forState:UIControlStateNormal];
                    }
                    else {
                        self.promoDescriptionLbl.text = @"Invalid Promo Code";
                        //[APPDELEGATE showToastMessage:@"Invalid Promo Code"];
                    }
                }
                else {
                    [self performSelector:@selector(hidePromoView:) withObject:self];
                    [APPDELEGATE showToastMessage:@"OOPS!! Something went wrong. Try Again"];
                }
            }];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (IBAction)applyPromoEvent:(id)sender {
    UIButton *promoBtn = sender;
    
    if([promoBtn.titleLabel.text isEqualToString:@"EDIT"]) {
        self.applyPromoTxt.text = @"";
        [self.applyPromoTxt becomeFirstResponder];
        
        [self.promoHeaderLbl setText:@"ADD PROMO"];
        [self.promoApplyBtn setTitle:@"ADD" forState:UIControlStateNormal];
        
        self.promoDescriptionLbl.text = @"No Promo added";
    }
    else if([promoBtn.titleLabel.text isEqualToString:@"ADD"]){
        if ([self.applyPromoTxt.text isEqualToString:@""]) {
            [APPDELEGATE showToastMessage:@"Please enter a valid promo code"];
        }
        else {
            [self removeKeyBoard];
        }
    }
}


- (IBAction)hidePromoView:(id)sender {
    [self.txtAddress setUserInteractionEnabled:YES];
}

-(void)paymentMode {
    NSMutableArray *paymentTypes = [[NSMutableArray alloc]initWithCapacity:0];
    if (isCOD) {
        [paymentTypes addObject:@"Pay via Cash"];
    }
    if (isCard) {
        [paymentTypes addObject:@"Pay via Card"];
    }
    if (isPaypal) {
        [paymentTypes addObject:@"Pay via PayPal"];
    }
    
    //COD
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Payment method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    popup.tag = 1;
    // ObjC Fast Enumeration
    for (NSString *title in paymentTypes) {
        [popup addButtonWithTitle:title];
    }
    
    popup.cancelButtonIndex = [popup addButtonWithTitle:@"Cancel"];
    
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *title = [popup buttonTitleAtIndex:buttonIndex];
    if (popup.tag == 1) {
        if ([title isEqual:@"Pay via Cash"]) {
            [pref setObject:@"1" forKey:PREF_PAYMENT_METHOD];
            [self.btnPaymentMethod setTitle:title forState:UIControlStateNormal];
        }
        else if ([title isEqual:@"Pay via Card"]) {
            [pref setObject:@"0" forKey:PREF_PAYMENT_METHOD];
            [self.btnPaymentMethod setTitle:title forState:UIControlStateNormal];
        }
        else if ([title isEqual:@"Pay via PayPal"]) {
            [pref setObject:@"2" forKey:PREF_PAYMENT_METHOD];
            [self.btnPaymentMethod setTitle:title forState:UIControlStateNormal];
        }
    }
    else if (popup.tag == 2) {
        if ([title isEqual:@"Pay Now"]) {
            [self payDebt];
        }
        else if ([title isEqual:@"Add card"]) {
            UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
            frontVC=[nav.childViewControllers objectAtIndex:0];
            
            if (frontVC) {
                [self.revealViewController rightRevealToggle:nil];
                [frontVC performSegueWithIdentifier:SEGUE_PAYMENT sender:frontVC];
            }
        }
    }
}

-(void)payDebt {
    
    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    
    if ([[AppDelegate sharedAppDelegate]connected]) {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_PAY_DEBT withParamData:dictParam withBlock:^(id response, NSError *error) {
            if ([[response valueForKey:@"success"] boolValue] == TRUE){
                [APPDELEGATE showToastMessage:@"You debts are cleared. Go on take a ride !!"];
            }
            else {
                [APPDELEGATE showToastMessage:@"OOPS!! Something went wrong. Try Again"];
            }
        }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getAllPaymentOptions {
    NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_PAYMENT_OPTIONS,PARAM_TOKEN,strForUserToken,PARAM_ID,strForUserId];
    
    if ([[AppDelegate sharedAppDelegate]connected]) {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error) {
            if (response) {
                if ([[response valueForKey:@"success"] boolValue] == true) {
                    ////NSLog(@"PAYMENT/PROMO OPTIONS -> %@",response);
                    isCOD = [[[response valueForKey:@"payment_options"] objectForKey:@"cod"] boolValue];
                    isCard = [[[response valueForKey:@"payment_options"] objectForKey:@"stored_cards"] boolValue];
                    isPaypal = [[[response valueForKey:@"payment_options"] objectForKey:@"paypal"] boolValue];
                    isPromo = [[response valueForKey:@"promo_allow"] boolValue];
                }
            }
        }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getNearbyProvidersForLat:(NSString *)latitude andLong:(NSString *)longitude {
    
    if(((strForLatitude==nil)&&(strForLongitude==nil))
       ||(([strForLongitude doubleValue]==0.00)&&([strForLatitude doubleValue]==0)))
    {
        [APPDELEGATE showToastMessage:NSLocalizedString(@"NOT_VALID_LOCATION", nil)];
        return;
    }
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:latitude forKey:PARAM_LATITUDE]; //12.911859
    [dictParam setValue:longitude forKey:PARAM_LONGITUDE]; //77.637862
    [dictParam setValue:@"1" forKey:PARAM_DISTANCE];
    
    if ([strForTypeid isEqualToString:@"0"]||strForTypeid==nil) {
        strForTypeid=@"1";
    }
    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
    
    if ([[AppDelegate sharedAppDelegate]connected]) {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_GET_NEARBY_PROVIDERS withParamData:dictParam withBlock:^(id response, NSError *error) {
            if (error) {
                [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                [self.etaBtn setTitle:@"No Drivers" forState:UIControlStateNormal];
                [addedMarkersArr removeAllObjects];
                [self deactivatePickmeBtn];
                [mapView_ clear];
            }
            else if (response) {
                
                if ([[response valueForKey:@"success"]boolValue] == true) {
                    driversArr = [[NSMutableArray alloc]initWithCapacity:0];
                    newMarkersArr = [[NSMutableArray alloc]initWithCapacity:0];
                    
                    [driversArr addObjectsFromArray:[response valueForKey:@"walkers"]];
                    
                    [mapView_ clear];
                    
                    for (int i=0; i<[driversArr count]; i++) {
                        NSString *lat = [[driversArr valueForKey:@"latitude"] objectAtIndex:i];
                        NSString *longi = [[driversArr valueForKey:@"longitude"] objectAtIndex:i];
                        
                        CLLocationCoordinate2D markPos;
                        markPos.latitude = [lat floatValue];
                        markPos.longitude = [longi floatValue];
                        
                        GMSMarker *mark = [GMSMarker markerWithPosition:markPos];
                        [newMarkersArr addObject:mark];
                    }
                    
                    for (int index=0; index<[driversArr count]; index++) {
                        DriverList *driverDetails = [[DriverList alloc]init];
                        driverDetails.latitude = [[driversArr valueForKey:@"latitude"] objectAtIndex:index];
                        driverDetails.longitude = [[driversArr valueForKey:@"longitude"] objectAtIndex:index];
                        driverDetails.type = [[driversArr valueForKey:@"type"] objectAtIndex:index];
                        driverDetails.distance = [[driversArr valueForKey:@"distance"] objectAtIndex:index];
                        driverDetails.index = [[[driversArr valueForKey:@"id"] objectAtIndex:index] integerValue];
                        
                        if (index == 0) {
                            [self getDistanceAndTimeFromLat:strForLatitude andLong:strForLongitude toLat:driverDetails.latitude andLong:driverDetails.longitude];
                            [self.etaBtn setTitle:[NSString stringWithFormat:@"Pickup in %@",strForETAtime] forState:UIControlStateNormal];
                        }
                        
                        //code to be executed in the background
                        [self addAnnotationWithTitle:self.txtAddress.text withLat:driverDetails.latitude andLong:driverDetails.longitude rateFor:driverDetails.timeCost tagVal:driverDetails.index];
                    }
                }
                else {
                    [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                    [self.etaBtn setTitle:@"No Drivers" forState:UIControlStateNormal];
                    [addedMarkersArr removeAllObjects];
                    [self deactivatePickmeBtn];
                    [mapView_ clear];
                }
            }
        }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getDistanceAndTimeFromLat:(NSString *)soucelat andLong:(NSString *)sourceLong toLat:(NSString *)destLat andLong:(NSString *)destLong {
    NSString *distUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%f,%f&destinations=%f,%f",[soucelat floatValue],[sourceLong floatValue],[destLat floatValue],[destLong floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:distUrl] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    NSArray *getDetails = [JSON objectForKey:@"rows"];
    NSArray *getRows = [[getDetails objectAtIndex:0] valueForKey:@"elements"];
    //    strForEstTime = [[[getRows objectAtIndex:0] valueForKey:@"duration"] objectForKey:@"value"];
    //    strForEstDist = [[[getRows objectAtIndex:0] valueForKey:@"distance"] objectForKey:@"value"];
    strForETAtime = [[[getRows objectAtIndex:0] valueForKey:@"duration"] objectForKey:@"text"];
}

// Adding dummy Annotation
-(void) addAnnotationWithTitle:(NSString *)title withLat:(NSString *)latitude andLong:(NSString *)longitude rateFor:(NSString *)rate tagVal:(int)tag {
    CLLocationCoordinate2D coord;
    
    coord.latitude=[latitude floatValue];
    coord.longitude=[longitude floatValue];
    GMSMarker *newMarker;
    
    //if ([addedMarkersArr count] > 0) {
    for (GMSMarker *marker in newMarkersArr) {
        if ([marker isEqual:[newMarkersArr objectAtIndex:0]]) {
            newMarker = [GMSMarker markerWithPosition:coord];
            //newMarker.appearAnimation = kGMSMarkerAnimationPop;
            newMarker.icon = [UIImage imageNamed:@"pin_driver_car"];
            newMarker.map = mapView_;
            newMarker.zIndex = tag;
            
            [addedMarkersArr addObject:newMarker];
            [self deactivatePickmeBtn];
        }
    }
    // }
    
    //    if (self.map.annotations.count == 0) {
    //        sbMapAnnot.appearAnimation = kGMSMarkerAnimationPop;
    //        sbMapAnnot.map = mapView_;
    //    }
    
    //    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    //
    //    for (GMSMarker *marker in markersArr)
    //        bounds = [bounds includingCoordinate:marker.position];
    //
    //    [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
    
}

-(NSString *) getAddressForLat:(NSString *)latitude andLong:(NSString *)longitude {
    
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[latitude floatValue], [longitude floatValue], [latitude floatValue], [longitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    
    NSDictionary *getRoutes = [JSON valueForKey:@"routes"];
    NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
    NSArray *getAddress = [getLegs valueForKey:@"end_address"];
    NSString *currentAdd;
    if (getAddress.count!=0)
    {
        currentAdd=[[getAddress objectAtIndex:0]objectAtIndex:0];
    }
    return currentAdd;
}

- (IBAction)choosePaymentMethod:(id)sender {
    [self paymentMode];
}

- (IBAction)showFareView:(id)sender {
    CarTypeDataModal *obj = [[CarTypeDataModal alloc]init];
    obj = [arrForApplicationType objectAtIndex:typeID];
    
    NSString *currencyType = [[NSUserDefaults standardUserDefaults]objectForKey:@"defaultCurrency"];
    
    self.carTypeLbl.text = [NSString stringWithFormat:@"%@",obj.name];
    
    self.basePriceLbl.text = [NSString stringWithFormat:@"%@ %.2f",currencyType,[obj.base_price floatValue]];
    self.perKmPriceLbl.text = [NSString stringWithFormat:@"%@ %.2f",currencyType,[obj.price_per_unit_distance floatValue]];
    self.perMinPriceLbl.text = [NSString stringWithFormat:@"%@ %.2f",currencyType,[obj.price_per_unit_time floatValue]];
    
    self.fareCardView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.txtAddress setUserInteractionEnabled:NO];
    self.fareCardView.backgroundColor = [Helper getColorFromHexString:@"#000000" :0.7f];
    [self.view addSubview:self.fareCardView];
    [self.view bringSubviewToFront:self.fareCardView];
}

- (IBAction)hideFareView:(id)sender {
    [self.txtAddress setUserInteractionEnabled:YES];
    [self.fareCardView removeFromSuperview];
}

- (IBAction)cancelRideEvent:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:PREF_IS_OPTIONS];
    
    if ([self.btnSelService isHidden]) {
        [self.btnAddDestination setHidden:YES];
        [self animateViewHeight:self.btnSelService withAnimationType:kCATransitionFromTop];
        [self animateViewHeight:self.optionsView withAnimationType:kCATransitionFromBottom];
        [self performSelector:@selector(closeDestinationEvent:) withObject:self];
        [self animateViewHeight:self.pickmeBg withAnimationType:kCATransitionFromBottom];
        [self animateViewHeight:self.btnPickMeUp withAnimationType:kCATransitionFromBottom];
    }
    else {
        [self.btnAddDestination setHidden:NO];
        [self animateViewHeight:self.btnSelService withAnimationType:kCATransitionFromBottom];
        [self animateViewHeight:self.optionsView withAnimationType:kCATransitionFromTop];
        [self performSelector:@selector(closeDestinationEvent:) withObject:self];
        [self animateViewHeight:self.pickmeBg withAnimationType:kCATransitionFromTop];
        [self animateViewHeight:self.btnPickMeUp withAnimationType:kCATransitionFromTop];
    }
}


- (IBAction)requestRideEvent:(id)sender {
    [self createRequest];
}

- (IBAction)addDestinationEvent:(id)sender {
    if ([self.destinationView isHidden] && [self.destLocationTxt.text isEqualToString:@""]) {
        [self animateViewHeight:self.destinationView withAnimationType:kCATransitionFromBottom];
        [self.btnAddDestination setHidden:YES];
    }
    else {
        [self animateViewHeight:self.destinationView withAnimationType:kCATransitionFromBottom];
        [self.btnAddDestination setHidden:NO];
    }
}

- (IBAction)closeDestinationEvent:(id)sender {
    [self.view endEditing:YES];
    [self.destLocationTxt setText:@""];
    
    if ([self.destinationView isHidden] && [self.destLocationTxt.text isEqualToString:@""]) {
        //[self animateViewHeight:self.destinationView withAnimationType:kCATransitionFromTop];
        [self.btnAddDestination setHidden:YES];
    }
    else {
        [self animateViewHeight:self.destinationView withAnimationType:kCATransitionFromTop];
        [self.btnAddDestination setHidden:NO];
    }
}

- (void)animateViewHeight:(UIView*)animateView withAnimationType:(NSString*)animType {
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:animType];
    
    [animation setDuration:0.5];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[animateView layer] addAnimation:animation forKey:kCATransition];
    animateView.hidden = !animateView.hidden;
}

@end

