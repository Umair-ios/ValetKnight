//
//  ProviderDetailsVC.h
//  UberNewUser
//
//  Created by Deep Gami on 29/10/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import "MapView.h"
#import "Place.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import <GoogleMaps/GoogleMaps.h>
#import "THContactPickerView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@class RatingBar;

@interface ProviderDetailsVC : BaseVC <MKMapViewDelegate,CLLocationManagerDelegate,GMSMapViewDelegate,UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>
{
    UIImageView* routeView;
    NSArray* routes;
    UIColor* lineColor;
    NSString *strTime;
    
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnShareEta;
@property (strong , nonatomic) NSTimer *timerForCheckReqStatuss;
@property (strong , nonatomic) NSTimer *timerForTimeAndDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIButton *revealBtnItem;
@property (weak, nonatomic) IBOutlet UILabel *lblRateValue;
@property (weak, nonatomic) IBOutlet UIImageView *imgForDriverProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnMin;
@property (weak, nonatomic) IBOutlet UIButton *btnDistance;


@property (nonatomic,strong) NSString *strForLatitude;
@property (nonatomic,strong) NSString *strForLongitude;
@property (nonatomic,strong) NSString *strForWalkStatedLatitude;
@property (nonatomic,strong) NSString *strForWalkStatedLongitude;
@property (nonatomic,strong) NSString *strForDropLatitude;
@property (nonatomic,strong) NSString *strForDropLongitude;
@property (nonatomic,strong) NSString *strTime;

@property (nonatomic,strong) NSTimer *timerforpathDraw;
- (IBAction)contactProviderBtnPressed:(id)sender;
-(int)checkDriverStatus;


@property (weak, nonatomic) IBOutlet UIButton *btnStatus;


@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;

@property (nonatomic,strong) MKPolyline *polyline;
@property(nonatomic,strong) CrumbPath *crumbs;
@property (nonatomic,strong) CrumbPathView *crumbView;

////////// Notification View
- (IBAction)statusBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *lblWalkerStarted;
@property (weak, nonatomic) IBOutlet UILabel *lblWalkerArrived;
@property (weak, nonatomic) IBOutlet UILabel *lblJobStart;
@property (weak, nonatomic) IBOutlet UILabel *lblJobDone;


@property (weak, nonatomic) IBOutlet UIButton *btnWalkerStart;
@property (weak, nonatomic) IBOutlet UIButton *btnWalkerArrived;
@property (weak, nonatomic) IBOutlet UIButton *btnJobStart;
@property (weak, nonatomic) IBOutlet UIButton *btnJobDone;
@property (weak, nonatomic) IBOutlet UIView *acceptView;
@property (weak, nonatomic) IBOutlet UILabel *lblAccept;

@property (weak, nonatomic) IBOutlet RatingBar *ratingView;

@property (weak, nonatomic) IBOutlet UIView *viewForMap;

@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, readonly) NSArray *selectedContacts;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, readonly) NSArray *filteredContacts;

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) didChangeSelectedItems;
- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;


@end
