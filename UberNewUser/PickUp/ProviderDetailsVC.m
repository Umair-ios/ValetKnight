//
//  ProviderDetailsVC.m
//  UberNewUser
//
//  Created by Deep Gami on 29/10/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ProviderDetailsVC.h"
#import "SWRevealViewController.h"
#import "sbMapAnnotation.h"
#import "UIImageView+Download.h"
#import "FeedBackVC.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "Constants.h"
#import "RateView.h"
#import "UIView+Utils.h"
#import "Helper.h"

@interface ProviderDetailsVC () <THContactPickerDelegate>
{
    NSDate *dateForwalkStartedTime;

    BOOL isTimerStaredForMin,isWalkInStarted,pathDraw;
    NSMutableArray *arrPath;
    GMSMutablePath *pathUpdates;
    NSString *strUSerImage,*strLastName,*strForDropETA;
    NSString *strProviderPhone,*strDistance;
    GMSMapView *mapView_;
    GMSMarker *client_marker,*driver_marker,*dropMarker;
    NSMutableArray *contactArr, *nameArray, *numbersArray, *allContactsArr;
    NSMutableDictionary *contactDict, *allContactsDict;
}

@property (weak, nonatomic) IBOutlet UIView *shareEtaView;
@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnShareCance;
@property (weak, nonatomic) IBOutlet UIButton *btnFullCallProvider;

@end

@implementation ProviderDetailsVC

static const CGFloat kPickerViewHeight = 100.0;

NSString *THContactPickerContactCellReuseID = @"THContactPickerContactCell";

@synthesize contactPickerView = _contactPickerView;

@synthesize strForLongitude,strForLatitude,strForWalkStatedLatitude,strForWalkStatedLongitude,strForDropLatitude,strForDropLongitude,timerForTimeAndDistance,timerForCheckReqStatuss;
#pragma mark -
#pragma mark - View DidLoad

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.statusView.hidden=YES;
    //strForLatitude=@"37.30000";
    //strForLongitude=@"-122.031";
    APPDELEGATE.vcProvider=self;
    [super setNavBarTitle:TITLE_PICKUP];
    [self customSetup];
    [self updateLocationManager];
    [self checkDriverStatus];
    
    arrPath=[[NSMutableArray alloc]init];
    contactArr = [[NSMutableArray alloc]init];
    allContactsDict = [[NSMutableDictionary alloc]init];
    contactDict = [[NSMutableDictionary alloc]init];
    allContactsArr = [[NSMutableArray alloc]init];
    
    pathUpdates = [GMSMutablePath path];
    pathUpdates = [[GMSMutablePath alloc]init];
    isTimerStaredForMin=NO;
    pathDraw=YES;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForLatitude doubleValue] longitude:[strForLongitude doubleValue]
                                                                 zoom:14];
    mapView_=[GMSMapView mapWithFrame:CGRectMake(0, 0,320,327) camera:camera];
    mapView_.myLocationEnabled = NO;
    [self.viewForMap addSubview:mapView_];
    [APPDELEGATE.window bringSubviewToFront:self.statusView];
    mapView_.delegate=self;
    
    
    //Creates a marker in the client Location of the map.
    client_marker = [[GMSMarker alloc] init];
    client_marker.position = CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    client_marker.icon=[UIImage imageNamed:@"pin_client_org"];
    client_marker.map = mapView_;
    
    //Creates a marker in the client Location of the map.
    driver_marker = [[GMSMarker alloc] init];
    driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
    driver_marker.icon=[UIImage imageNamed:@"pin_driver_car"];
    driver_marker.map = mapView_;
    
    //Creates a marker in the client Location of the map.
    dropMarker = [[GMSMarker alloc] init];
    dropMarker.position = CLLocationCoordinate2DMake([strForDropLatitude doubleValue], [strForDropLongitude doubleValue]);
    NSString *eta = [self getDistanceAndTimeFromLat:strForLatitude andLong:strForLongitude toLat:strForDropLatitude andLong:strForDropLongitude];
    if (eta == NULL || [eta isEqual:@""] || [eta isEqualToString:@""]) {
        [self.btnShareEta setHidden:YES];
        [self.btnCall setHidden:YES];
        [self.btnFullCallProvider setHidden:NO];
        //[self.btnCall setFrame:CGRectMake(1, self.btnCall.frame.origin.y, 318, self.btnCall.frame.size.width)];
        //[self.btnCall setTitle:@"CALL PROVIDER" forState:UIControlStateNormal];
    }
    else {
        [self.btnShareEta setHidden:NO];
        [self.btnCall setHidden:NO];
        [self.btnFullCallProvider setHidden:YES];

        [self.btnShareEta setTitle:[NSString stringWithFormat:@"SHARE ETA (%@)",eta] forState:UIControlStateNormal];
    }
    //dropMarker.title = [self getDistanceAndTimeFromLat:strForLatitude andLong:strForLongitude toLat:strForDropLatitude andLong:strForDropLongitude];
    dropMarker.map = mapView_;

    timerForCheckReqStatuss = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForTripStatus) userInfo:nil repeats:YES];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    isWalkInStarted=[pref boolForKey:PREF_IS_WALK_STARTED];
    if(isWalkInStarted)
    {
        [self requestPath];
    }
    self.acceptView.hidden=NO;
    self.lblStatus.text=@"Status :  Accepted the Job";
    
    [self customFont];
    
    [self getSortedContacts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    UITapGestureRecognizer *tapToRemoveKeyboard = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeKeyboardToShowBtns)];
//    [tapToRemoveKeyboard setNumberOfTapsRequired:1];
//    [tapToRemoveKeyboard setDelegate:self];
//    [self.view addGestureRecognizer:tapToRemoveKeyboard];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"tripDone"];

    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.ratingView initRateBar];
    [self.ratingView setUserInteractionEnabled:NO];
    
    [self.imgForDriverProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self checkForTripStatus];
}

/*
 #pragma mark-
 #pragma mark- timer for oath draw
 
 -(void)setTimerToCheckDriverStatus
 {
 self.timerforpathDraw = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(setPathDrawBool) userInfo:nil repeats:YES];
 }
 
 -(void)setPathDrawBool
 {
 pathDraw=YES;
 }
 */

#pragma mark-
#pragma mark- customFont

-(void)customFont
{
    /*
     self.lblDriverDetail.font=[UberStyleGuide fontRegular:13.0f];
     self.lblDriverName.font=[UberStyleGuide fontRegular:13.0f];
     self.lblJobDone.font=[UberStyleGuide fontRegular:13.0f];
     self.lblJobStart.font=[UberStyleGuide fontRegular:13.0f];
     self.lblWalkerArrived.font=[UberStyleGuide fontRegular:13.0f];
     self.lblWalkerStarted.font=[UberStyleGuide fontRegular:13.0f];
     */
    
    self.lblAccept.font=[UberStyleGuide fontRegular];
    self.lblAccept.textColor=[UberStyleGuide colorDefault]; //btnShareEta
    
    self.btnShareEta=[APPDELEGATE setBoldFontDiscriptor:self.btnShareEta];
    self.btnCall=[APPDELEGATE setBoldFontDiscriptor:self.btnCall];
    self.btnFullCallProvider=[APPDELEGATE setBoldFontDiscriptor:self.btnFullCallProvider];
    self.btnDistance.titleLabel.font=[UberStyleGuide fontRegular];
    self.btnMin.titleLabel.font=[UberStyleGuide fontRegular];
}

#pragma mark -
#pragma mark - Location Delegate


-(void)updateLocationManager
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
           fromLocation:(CLLocation *)oldLocation
{
    strForLatitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    strForLongitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    isWalkInStarted=[pref boolForKey:PREF_IS_WALK_STARTED];
    
    if(isWalkInStarted)
    {
        if (newLocation != nil) {
            if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude) {
                
            }else{
                //Code for
                //CLLocationDistance meters = [oldLocation distanceFromLocation:newLocation];
                //distance += (meters/1609);
                //[self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f Miles",distance] forState:UIControlStateNormal];
                //[self checkTimeAndDistance];
                /*if (pathDraw)
                 {
                 pathDraw=NO;
                 [self updateMapLocation:newLocation];
                 }*/
                //[self updateMapLocation:newLocation];
                
                [pathUpdates addCoordinate:newLocation.coordinate];
                
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathUpdates];
                polyline.strokeColor = [UIColor blueColor];
                polyline.strokeWidth = 5.f;
                polyline.geodesic = YES;
                
                polyline.map = mapView_;
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    ////NSLog(@"didFailWithError: %@", error);
    
    /*UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     alertLocation.tag=100;
     [alertLocation show];
     */
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.revealBtnItem addTarget:self.revealViewController action:@selector( revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
        /*
         [self.revealButtonItem setTarget: self.revealViewController];
         [self.revealButtonItem setAction: @selector( revealToggle: )];
         */
        //[self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark -
#pragma mark - Mapview Delegate

-(void)showDriverLocatinOnMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForWalkStatedLatitude doubleValue] longitude:[strForWalkStatedLongitude doubleValue]
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
    //self.view = mapView_;
    [self.viewForMap addSubview:mapView_];
    // mapView_.delegate=self;
    
    driver_marker = [[GMSMarker alloc] init];
    driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
    driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
    driver_marker.map = mapView_;
    //    CLLocationCoordinate2D l;
    //    l.latitude=[strForWalkStatedLatitude doubleValue];
    //    l.longitude=[strForWalkStatedLongitude doubleValue];
    //    SBMapAnnotation *annotation= [[SBMapAnnotation alloc]initWithCoordinate:l];
    //    annotation.yTag=1002;
    //    [self.mapView addAnnotation:annotation];
    //    [self.mapView setRegion:MKCoordinateRegionMake([annotation coordinate], MKCoordinateSpanMake(.5, .5)) animated:YES];
}

-(void)showMapCurrentLocatin
{
    if([CLLocationManager locationServicesEnabled])
    {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForLatitude doubleValue] longitude:[strForLongitude doubleValue]
                                                                     zoom:14];
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
        mapView_.myLocationEnabled = NO;
        //self.view = mapView_;
        [self.viewForMap addSubview:mapView_];
        // mapView_.delegate=self;
        // Creates a marker in the client Location of the map.
        client_marker = [[GMSMarker alloc] init];
        client_marker.position = CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
        client_marker.icon=[UIImage imageNamed:@"pin_client_org"];
        client_marker.map = mapView_;
        
        //        CLLocationCoordinate2D l;
        //        l.latitude=[strForLatitude doubleValue];
        //        l.longitude=[strForLongitude doubleValue];
        //        SBMapAnnotation *annotation= [[SBMapAnnotation alloc]initWithCoordinate:l];
        //        annotation.yTag=1001;
        //        [self.mapView addAnnotation:annotation];
        //        [self.mapView setRegion:MKCoordinateRegionMake([annotation coordinate], MKCoordinateSpanMake(.5, .5)) animated:YES];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
}

//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    if ([annotation isKindOfClass:[MKUserLocation class]])
//        return nil;
//
//    //Annotations
//    MKPinAnnotationView *pinAnnotation = nil;
//    if(annotation != self.mapView.userLocation)
//    {
//        // Dequeue the pin
//        static NSString *defaultPinID = @"myPin";
//        pinAnnotation = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//        if ( pinAnnotation == nil )
//            pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
//
//        SBMapAnnotation *sbanno=(SBMapAnnotation *)annotation;
//
//        if(sbanno.yTag==1001)
//            pinAnnotation.image = [UIImage imageNamed:@"pin_client_org"];
//        else
//            pinAnnotation.image = [UIImage imageNamed:@"pin_driver"];
//
//        pinAnnotation.centerOffset = CGPointMake(0, -20);
//        pinAnnotation.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        pinAnnotation.canShowCallout=YES;
//        pinAnnotation.draggable=YES;
//    }
//    return pinAnnotation;
//}
//- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers {
//
//    [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(1, 1, 1, 1) animated:YES];
//
//}
//
//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
//{
//    if (!self.crumbView)
//    {
//        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
//    }
//    return self.crumbView;
//}

#pragma mark -
#pragma mark - Custom Methods

-(float)calculateDistanceFrom:(CLLocation *)locA To:(CLLocation *)locB
{
    CLLocationDistance distance;
    distance=[locA distanceFromLocation:locB];
    float Range=distance;
    return Range;
}
#pragma mark-
#pragma mark- Calculate Time & Distance

-(void)updateTime:(NSString *)starTime
{
    /*
     NSString *currentTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]*1000];
     
     double start = [starTime doubleValue];
     double end=[currentTime doubleValue];
     
     NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]];
     
     ////NSLog(@"difference: %f", difference);
     
     int time=(difference/(1000*60));
     
     if(time==0)
     {
     time=1;
     }
     
     [self.btnMin setTitle:[NSString stringWithFormat:@"%d min",time] forState:UIControlStateNormal];
     */
    
    
    
    NSString *gmtDateString = starTime;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *datee = [df dateFromString:gmtDateString];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    
    
    double dateTimeDiff=  [[NSDate date] timeIntervalSince1970] - [datee timeIntervalSince1970];
    int Diff=dateTimeDiff/60;
    strTime=[NSString stringWithFormat:@"%d Min",Diff];
    [self.btnMin setTitle:[NSString stringWithFormat:@"%d Min",Diff] forState:UIControlStateNormal];
    ////NSLog(@"Min %d",Diff);
}

-(void)checkForTripStatus
{
    if([[AppDelegate sharedAppDelegate]connected]) {
        
        [self.btnShareEta setTitle:[NSString stringWithFormat:@"SHARE ETA (%@)",[self getDistanceAndTimeFromLat:strForLatitude andLong:strForLongitude toLat:strForDropLatitude andLong:strForDropLongitude]] forState:UIControlStateNormal];

        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];

        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             ////NSLog(@"GET REQ--->%@",response);
             if (response) {
                 
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                     self.lblRateValue.text=[NSString stringWithFormat:@"%.1f",[[dictWalker valueForKey:@"rating"] floatValue]];
                     
                     RBRatings rate=([[dictWalker valueForKey:@"rating"]floatValue]*2);
                     [self.ratingView setRatings:rate];
                     
                     strLastName=[dictWalker valueForKey:@"last_name"];
                     self.lblDriverName.text=[NSString stringWithFormat:@"%@ %@",[dictWalker valueForKey:@"first_name"],strLastName];
                     
                     self.lblDriverDetail.text=[dictWalker valueForKey:@"phone"];
                     strProviderPhone=[NSString stringWithFormat:@"%@",[dictWalker valueForKey:@"phone"]];
                     [self.imgForDriverProfile downloadFromURL:[dictWalker valueForKey:@"picture"] withPlaceholder:nil];
                     strUSerImage=[dictWalker valueForKey:@"picture"];
                     
                     is_walker_started=[[response valueForKey:@"is_walker_started"] intValue];
                     is_walker_arrived=[[response valueForKey:@"is_walker_arrived"] intValue];
                     is_started=[[response valueForKey:@"is_walk_started"] intValue];
                     is_completed=[[response valueForKey:@"is_completed"] intValue];
                     is_dog_rated=[[response valueForKey:@"is_walker_rated"] intValue];
                     
                     strDistance=[NSString stringWithFormat:@"%.2f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]];
                     if ([response valueForKey:@"start_time"]) {
                         [self updateTime:[response valueForKey:@"start_time"]];
                     }
                     else {
                         strTime = [response valueForKey:@"time"];
                     }

                     if (is_completed == 1) {
                         [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"tripDone"];
                         dictBillInfo=[response valueForKey:@"bill"];
                     }

 /*
                     if(is_completed==1)
                     {
                         isWalkInStarted=NO;
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
                         
                         dictBillInfo=[response valueForKey:@"bill"];
                         
                         FeedBackVC *vcFeed = nil;
                         for (int i=0; i<self.navigationController.viewControllers.count; i++)
                         {
                             UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                             if ([vc isKindOfClass:[FeedBackVC class]])
                             {
                                 
                                 vcFeed = (FeedBackVC *)vc;
                             }
                         }
                         if (vcFeed==nil)
                         {
                             [timerForCheckReqStatuss invalidate];
                             [timerForTimeAndDistance invalidate];
                             timerForTimeAndDistance=nil;
                             timerForCheckReqStatuss=nil;
                             [self.timerforpathDraw invalidate];
                             
                             [self performSegueWithIdentifier:SEGUE_TO_FEEDBACK sender:self];
                         }else{
                             [self.navigationController popToViewController:vcFeed animated:NO];
                         }
                     }
  */
                     [self checkDriverStatus];

                     if(is_started==1)
                     {
                         [locationManager startUpdatingLocation];
                         [self updateTime:[response valueForKey:@"start_time"]];
                         [self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]] forState:UIControlStateNormal];
                         
                         isWalkInStarted=YES;
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
                         
                         if(isTimerStaredForMin==NO)
                         {
                             isTimerStaredForMin=YES;
                             // [self checkTimeAndDistance];
                             dateForwalkStartedTime=[NSDate date];
                             // timerForTimeAndDistance= [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkTimeAndDistance) userInfo:nil repeats:YES];
                         }
                         strForWalkStatedLatitude=[dictWalker valueForKey:@"latitude"];
                         strForWalkStatedLongitude=[dictWalker valueForKey:@"longitude"];
                     }
                     strForWalkStatedLatitude=[dictWalker valueForKey:@"latitude"];
                     strForWalkStatedLongitude=[dictWalker valueForKey:@"longitude"];
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

-(void)requestPath
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
    NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
    
    
    NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_REQUEST_PATH,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
    
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         
         ////NSLog(@"Page Data= %@",response);
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 [arrPath removeAllObjects];
                 arrPath=[response valueForKey:@"locationdata"];
                 [self drawPath];
             }
         }
         
     }];
}

-(int)checkDriverStatus
{
    // To note that ride is not yet completed
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isRideCompleted"];
    
    if(is_walker_started==1)
    {
        [self.btnWalkerStart setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Provider has started moving towards you.";
        self.lblAccept.text=@"DRIVER HAS STARTED MOVING TOWARDS YOU";
        
        self.lblWalkerStarted.textColor=[UberStyleGuide colorDefault];
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;
    }

    if(is_walker_arrived==1)
    {
        [self.btnWalkerArrived setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Provider has arrived at your place.";
        self.lblAccept.text=@"DRIVER HAS ARRIVED AT YOUR PLACE";
        
        self.lblWalkerArrived.textColor=[UberStyleGuide colorDefault];
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;
    }

    if(is_started==1)
    {
        [self.btnJobStart setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Your trip has been started.";
        self.lblAccept.text=@"YOUR TRIP HAS BEEN STARTED";
        
        self.lblJobStart.textColor=[UberStyleGuide colorDefault];
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;
        
        client_marker.map = nil;
    }
    
    if(is_dog_rated==1)
    {
        
    }
    
    if(is_completed==1)
    {
        [self.btnJobDone setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        
        self.lblJobDone.textColor=[UberStyleGuide colorDefault];
        isWalkInStarted=NO;
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
        
        // To stop late push from being triggered
        [pref setBool:YES forKey:@"isRideCompleted"];

        if ([dictBillInfo valueForKey:@"time"]) {
            strTime = [NSString stringWithFormat:@"%@ Min",[dictBillInfo valueForKey:@"time"]];
        }
        
        FeedBackVC *vcFeed = nil;
        for (int i=0; i<self.navigationController.viewControllers.count; i++)
        {
            UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
            if ([vc isKindOfClass:[FeedBackVC class]])
            {
                vcFeed = (FeedBackVC *)vc;
            }
        }
        if (vcFeed==nil)
        {
            [timerForCheckReqStatuss invalidate];
            [timerForTimeAndDistance invalidate];
            timerForTimeAndDistance=nil;
            timerForCheckReqStatuss=nil;
            [self.timerforpathDraw invalidate];
            
            //if (![[NSUserDefaults standardUserDefaults]boolForKey:@"tripDone"]) {
                [self performSegueWithIdentifier:SEGUE_TO_FEEDBACK sender:self];
            //}
        }
        else{
            [self.navigationController popToViewController:vcFeed animated:NO];
        }
    }
    
    if (self.statusView.hidden==NO)
    {
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box_arived"] forState:UIControlStateNormal];
    }
    
    return 5;
}

#pragma mark -
#pragma mark - Draw Route Methods

-(void)drawPath
{
    NSMutableDictionary *dictPath=[[NSMutableDictionary alloc]init];
    NSString *templati,*templongi;
    
    //NSMutableArray *paths=[[NSMutableArray alloc]init];
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<arrPath.count; i++)
    {
        dictPath=[arrPath objectAtIndex:i];
        templati=[dictPath valueForKey:@"latitude"];
        templongi=[dictPath valueForKey:@"longitude"];
        
        CLLocationCoordinate2D current;
        current.latitude=[templati doubleValue];
        current.longitude=[templongi doubleValue];
        //CLLocation *curLoc = [[CLLocation alloc]initWithLatitude:current.latitude longitude:current.longitude];
        
        //[paths addObject:curLoc];
        [path addCoordinate:current];
        
        //[self updateMapLocation:curLoc];
    }
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = [UIColor blueColor];
    polyline.strokeWidth = 5.f;
    polyline.geodesic = YES;
    polyline.map = mapView_;
}

//- (void)updateMapLocation:(CLLocation *)newLocation
//{
//
//    self.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
//    self.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
//    for (MKAnnotationView *annotation in self.mapView.annotations) {
//        if ([annotation isKindOfClass:[SBMapAnnotation class]])
//        {
//            SBMapAnnotation *sbAnno = (SBMapAnnotation *)annotation;
//            if(sbAnno.yTag==1001)
//                [sbAnno setCoordinate:newLocation.coordinate];
//            if (!self.crumbs)
//            {
//                _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
//                [self.mapView addOverlay:self.crumbs];
//
//                MKCoordinateRegion region =
//                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
//                [self.mapView setRegion:region animated:YES];
//            }
//            else{
//                MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
//
//                if (!MKMapRectIsNull(updateRect))
//                {
//                    MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
//                    // Find out the line width at this zoom scale and outset the updateRect by that amount
//                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
//                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
//                    // Ask the overlay view to update just the changed area.
//                    [self.crumbView setNeedsDisplayInMapRect:updateRect];
//
//                    [self.mapView setVisibleMapRect:updateRect edgePadding:UIEdgeInsetsMake(1, 1, 1, 1) animated:YES];
//                }
//            }
//        }
//
//    }
//}
- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        //printf("[%f,", [latitude doubleValue]);
        //printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    ////NSLog(@"api url: %@", apiUrl);
    NSError* error = nil;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    NSString *encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void) centerMap
{
    MKCoordinateRegion region;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees minLon = 180.0;
    for(int idx = 0; idx < routes.count; idx++)
    {
        CLLocation* currentLocation = [routes objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    region.center.latitude     = (maxLat + minLat) / 2.0;
    region.center.longitude    = (maxLon + minLon) / 2.0;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    
    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
    // [self.mapView setRegion:region animated:YES];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=region.center.latitude;
    coordinate.longitude=region.center.longitude;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
}


//-(void) showRouteFrom:(id < MKAnnotation>)f to:(id < MKAnnotation>  )t
//{
//    if(routes)
//    {
//        [self.mapView removeAnnotations:[self.mapView annotations]];
//    }
//
//    [self.mapView addAnnotation:f];
//    [self.mapView addAnnotation:t];
//
//    routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
//    NSInteger numberOfSteps = routes.count;
//
//    CLLocationCoordinate2D coordinates[numberOfSteps];
//    for (NSInteger index = 0; index < numberOfSteps; index++)
//    {
//        CLLocation *location = [routes objectAtIndex:index];
//        CLLocationCoordinate2D coordinate = location.coordinate;
//        coordinates[index] = coordinate;
//    }
//    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
//    [self.mapView addOverlay:polyLine];
//    [self centerMap];
//}

#pragma mark -
#pragma mark - MKPolyline delegate functions

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSMutableDictionary *dictWalkInfo=[[NSMutableDictionary alloc]init];
    NSString *distance= strDistance;
    
    NSArray *arrDistace=[distance componentsSeparatedByString:@" "];
    float dist;
    dist=[[arrDistace objectAtIndex:0]floatValue];
    if (arrDistace.count>1)
    {
        if ([[arrDistace objectAtIndex:1] isEqualToString:@"kms"])
        {
            dist=dist*0.621371;
        }
    }
    [dictWalkInfo setObject:[NSString stringWithFormat:@"%f",dist] forKey:@"distance"];
    if (strTime == NULL) {
        strTime = @"0";
    }
    [dictWalkInfo setObject:strTime forKey:@"time"];
    
    if([segue.identifier isEqualToString:SEGUE_TO_FEEDBACK])
    {
        FeedBackVC *obj=[segue destinationViewController];        
        obj.dictWalkInfo=dictWalkInfo;
        obj.strUserImg=strUSerImage;
        obj.strFirstName=self.lblDriverName.text;
    }
}

- (IBAction)contactProviderBtnPressed:(id)sender
{
    NSString *call=[NSString stringWithFormat:@"tel://%@",strProviderPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call]];
}


- (IBAction)statusBtnPressed:(id)sender
{
    self.acceptView.hidden=YES;
    if (self.statusView.hidden==YES)
    {
        self.statusView.hidden=NO;
        [APPDELEGATE.window addSubview:self.statusView];
        [APPDELEGATE.window bringSubviewToFront:self.statusView];
    }
    else
    {
        self.statusView.hidden=YES;
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        [APPDELEGATE.window bringSubviewToFront:self.statusView];
    }
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

-(NSString *)getDistanceAndTimeFromLat:(NSString *)soucelat andLong:(NSString *)sourceLong toLat:(NSString *)destLat andLong:(NSString *)destLong {
    NSString *distUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%f,%f&destinations=%f,%f",[soucelat floatValue],[sourceLong floatValue],[destLat floatValue],[destLong floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:distUrl] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    NSArray *getDetails = [JSON objectForKey:@"rows"];
    NSArray *getRows = [[getDetails objectAtIndex:0] valueForKey:@"elements"];
    //    strForEstTime = [[[getRows objectAtIndex:0] valueForKey:@"duration"] objectForKey:@"value"];
    //    strForEstDist = [[[getRows objectAtIndex:0] valueForKey:@"distance"] objectForKey:@"value"];
    strForDropETA = [[[getRows objectAtIndex:0] valueForKey:@"duration"] objectForKey:@"text"];
    return strForDropETA;
}


- (IBAction)shareEtaEvent:(id)sender {
    if ([self.shareEtaView isHidden]) {
        [self.shareEtaView setHidden:NO];
        [self.revealBtnItem setTitle:@"  Share ETA" forState:UIControlStateNormal];
        [self createContactPickerView];
    }
    else {
        [self.revealBtnItem setTitle:@"" forState:UIControlStateNormal];
        [self.shareEtaView setHidden:YES];
    }
}

- (IBAction)shareETA:(id)sender {
    
}

-(void)createContactPickerView {
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight];
    }
    contactArr = [[NSMutableArray alloc]init];
    nameArray = [[NSMutableArray alloc]init];
    numbersArray = [[NSMutableArray alloc]init];
    
    [self provideAccessToContacts];
    
    self.contacts = nameArray;

    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 143, self.view.frame.size.width, kPickerViewHeight)];
    self.contactPickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderLabelText:@"Who would you like to share?"];
    [self.contactPickerView setPromptLabelText:@"To:"];

    [self.shareEtaView addSubview:self.contactPickerView];
    
    CALayer *layer = [self.contactPickerView layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Fill the rest of the view with the table view
    CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, 344);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.shareEtaView insertSubview:self.tableView belowSubview:self.contactPickerView];

    [self.shareEtaView bringSubviewToFront:self.btnShare];
    [self.shareEtaView bringSubviewToFront:self.btnShareCance];
}

-(void)removeKeyboardToShowBtns {
    [self.view endEditing:YES];
}

- (NSArray *)selectedContacts{
    return [self.privateSelectedContacts copy];
}

#pragma mark - Publick properties

- (NSArray *)filteredContacts {
    if (!_filteredContacts) {
        _filteredContacts = _contacts;
    }
    return _filteredContacts;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (NSInteger)selectedCount {
    return self.privateSelectedContacts.count;
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedContacts {
    if (!_privateSelectedContacts) {
        _privateSelectedContacts = [NSMutableArray array];
    }
    return _privateSelectedContacts;
}

#pragma mark - Private methods

/*
- (void)adjustTableFrame {
    CGFloat yOffset = self.contactPickerView.frame.origin.y + self.contactPickerView.frame.size.height;
    
    CGRect tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset);
    self.tableView.frame = tableFrame;
}
*/

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top bottom:bottomInset];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
}

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text {
    return [NSPredicate predicateWithFormat:@"self contains[cd] %@", text];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.filteredContacts objectAtIndex:indexPath.row];
}

- (void) didChangeSelectedItems {
    [self removeKeyboardToShowBtns];
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THContactPickerContactCellReuseID];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THContactPickerContactCellReuseID];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [tableView setTintColor:[Helper getColorFromHexString:@"#fb9d3e" :1.0f]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id contact = [self.filteredContacts objectAtIndex:indexPath.row];
    id number = [numbersArray objectAtIndex:indexPath.row];
    
    NSString *contactTilte = [self titleForRowAtIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:contact]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.privateSelectedContacts removeObject:contact];
        [allContactsArr removeObject:number];
        [self.contactPickerView removeContact:contact];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.privateSelectedContacts addObject:contact];
        [allContactsArr addObject:number];
        [self.contactPickerView addContact:contact withName:contactTilte];
    }
    
    self.filteredContacts = self.contacts;
    [self didChangeSelectedItems];
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [self newFilteringPredicateWithText:textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    CGRect frame = self.tableView.frame;
    frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    //frame.size.height = frame.size.height + contactPickerView.frame.size.height;
    self.tableView.frame = frame;
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.privateSelectedContacts removeObject:contact];
    
    NSInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self didChangeSelectedItems];
}

- (BOOL)contactPickerTextFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0){
        NSString *contact = [[NSString alloc] initWithString:textField.text];
        [self.privateSelectedContacts addObject:contact];
        [self.contactPickerView addContact:contact withName:textField.text];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

// Sorted list of Contacts
-(void)getSortedContacts {
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
   
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(people),
                                                               people);
    
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      kABPersonSortByFirstName);
    
    // or to sort by the address book's choosen sorting technique
    //
    // CFArraySortValues(peopleMutable,
    //                   CFRangeMake(0, CFArrayGetCount(peopleMutable)),
    //                   (CFComparatorFunction) ABPersonComparePeopleByName,
    //                   (void*) ABPersonGetSortOrdering());
    
    CFRelease(people);
    
    // If you don't want to have to go through this ABRecordCopyValue logic
    // in the rest of your app, rather than iterating through doing ////NSLog,
    // build a new array as you iterate through the records.
    
    for (CFIndex i = 0; i < CFArrayGetCount(peopleMutable); i++)
    {
        ABRecordRef record = CFArrayGetValueAtIndex(peopleMutable, i);
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
        ////NSLog(@"person = %@, %@", lastName, firstName);
        
        NSMutableDictionary *baseDict = [[NSMutableDictionary alloc]initWithCapacity:0];
        if (firstName != nil || lastName != nil) {
            if (firstName == nil) {
                firstName = @"";
            }
            
            if (lastName == nil) {
                lastName = @"";
            }
            
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
            ////NSLog(@"person.fullName = %@",fullName);
            
            [nameArray addObject:fullName];
            [baseDict setValue:fullName forKey:@"Name"];
            
            ABMultiValueRef phones =(__bridge ABMultiValueRef)(CFBridgingRelease(ABRecordCopyValue(record, kABPersonPhoneProperty)));
            NSString* mobile=@"";
            NSString* mobileLabel;
            for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
                mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
                
                if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
                {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    ////NSLog(@"person.contactNum = %@",mobile);
                    [numbersArray addObject:mobile];
                    
                    break;
                }
                else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    ////NSLog(@"person.contactNum = %@",mobile);
                    [numbersArray addObject:mobile];
                    break;
                }
                else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    ////NSLog(@"person.contactNum = %@",mobile);
                    [numbersArray addObject:mobile];
                    break;
                }
                else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    ////NSLog(@"person.contactNum = %@",mobile);
                    [numbersArray addObject:mobile];
                    break;
                }
                else {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, 0);
                    ////NSLog(@"person.contactNum = %@",mobile);
                    [numbersArray addObject:mobile];
                    break;
                }
            }
        }
    }
    
    CFRelease(peopleMutable);
}

// Unsorted list of Contacts
/*
- (void)getPersonOutOfAddressBook {
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook != nil) {
        ////NSLog(@"Succesful.");
        
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSUInteger i = 0;
        
        for (i = 0; i < [allContacts count]; i++) {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            NSMutableDictionary *baseDict = [[NSMutableDictionary alloc]initWithCapacity:0];
            if (firstName != nil || lastName != nil) {
                if (firstName == nil) {
                    firstName = @"";
                }
                
                if (lastName == nil) {
                    lastName = @"";
                }
                
                NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
                ////NSLog(@"person.fullName = %@",fullName);
                [nameArray addObject:fullName];
                [baseDict setValue:fullName forKey:@"Name"];
                
                ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(contactPerson, kABPersonPhoneProperty));
                NSString* mobile=@"";
                NSString* mobileLabel;
                for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
                    mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
                    
                    if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
                    {
                        mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                        ////NSLog(@"person.contactNum = %@",mobile);
//                        [baseDict setValue:mobile forKey:@"Number"];
                        [numbersArray addObject:mobile];
                        
                        break;
                    }
                    else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
                        mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                        ////NSLog(@"person.contactNum = %@",mobile);
//                        [baseDict setValue:mobile forKey:@"Number"];
                        [numbersArray addObject:mobile];
                        break;
                    }
                    else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
                        mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                        ////NSLog(@"person.contactNum = %@",mobile);
//                        [baseDict setValue:mobile forKey:@"Number"];
                        [numbersArray addObject:mobile];
                        break;
                    }
                    else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                        mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                        ////NSLog(@"person.contactNum = %@",mobile);
//                        [baseDict setValue:mobile forKey:@"Number"];
                        [numbersArray addObject:mobile];
                        break;
                    }
                    else {
                        mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, 0);
                        ////NSLog(@"person.contactNum = %@",mobile);
//                        [baseDict setValue:mobile forKey:@"Number"];
                        [numbersArray addObject:mobile];
                        break;
                    }
                }
//                [contactArr addObject:baseDict];
            }
        }
        CFRelease(addressBook);
    }
    else {
        ////NSLog(@"Error reading Address Book");
    }
}
*/

-(void)provideAccessToContacts {
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                //[self getPersonOutOfAddressBook];
                [self getSortedContacts];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Provide access to contacts from Settings -> Privacy -> Contacts -> App to share ETA"]  message:nil delegate:nil cancelButtonTitle:@"Settings" otherButtonTitles:@"Cancel", nil];
                
                [alert show];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        //[self getPersonOutOfAddressBook];
        [self getSortedContacts];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Provide access to contacts from Settings -> Privacy -> Contacts -> App to share ETA"]  message:nil delegate:nil cancelButtonTitle:@"Settings" otherButtonTitles:@"Cancel", nil];
        
        [alert show];
    }
}
- (IBAction)shareMyETA:(id)sender {
    [self sendNumbersForShareETA];
}

-(void)sendNumbersForShareETA {
    NSString *strForAllNum;
    strForAllNum = [allContactsArr componentsJoinedByString:@","];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
    NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];

    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
    [dictParam setObject:strForDropETA forKey:PARAM_ETA];
    [dictParam setObject:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setObject:strForUserId forKey:PARAM_ID];
    [dictParam setObject:strReqId forKey:PARAM_REQUEST_ID];
    [dictParam setObject:strForAllNum forKey:PARAM_PHONE];
    
    if ([[AppDelegate sharedAppDelegate]connected]) {
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:FILE_SHARE_ETA withParamData:dictParam withBlock:^(id response, NSError *error) {
        ////NSLog(@"SHARE ETA - %@",response);
    }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}



@end

