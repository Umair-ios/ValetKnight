//
//  PickUpVC.h
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface PickUpVC : BaseVC <MKMapViewDelegate,CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,GMSMapViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>
{
    NSTimer *timerForCheckReqStatus;
    CLLocationManager *locationManager;
    UIViewController *frontVC;
}

/////// Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewGoogleMap;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) IBOutlet UIButton* revealButtonItem;
@property(nonatomic,weak)IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIView *viewForMarker;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

/////// Actions

- (IBAction)pickMeUpBtnPressed:(id)sender;
- (IBAction)cancelReqBtnPressed:(id)sender;

- (IBAction)myLocationPressed:(id)sender;
- (IBAction)selectServiceBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSelService;
@property (weak, nonatomic) IBOutlet UIButton *btnPickMeUp;

-(void)goToSetting:(NSString *)str;



@end
