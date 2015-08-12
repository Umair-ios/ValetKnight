//
//  FeedBackVC.h
//  UberNewUser
//
//  Created by Deep Gami on 01/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import "RatingBar.h"
#import "SWRevealViewController.h"

@interface FeedBackVC : BaseVC<UITextViewDelegate>
{
    RatingBar *ratingView;
    
}

//////////// Outlets Price Label

@property (weak, nonatomic) IBOutlet UILabel *lblBasePrice;
@property (weak, nonatomic) IBOutlet UILabel *lblDistCost;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeCost;
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblPerDist;
@property (weak, nonatomic) IBOutlet UILabel *lblPerTime;



////////////
//@property (nonatomic,strong) NSMutableDictionary *dictBillInfo;
@property (nonatomic,strong) NSString *strUserImg;

@property (nonatomic,strong) NSMutableDictionary *dictWalkInfo;
@property (nonatomic,strong) NSString *strFirstName;
@property (nonatomic, strong) NSString *strLastName;

@property (weak, nonatomic) IBOutlet UIButton *barButton;
@property (weak, nonatomic) IBOutlet UITextView *txtComments;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;

- (IBAction)submitBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTIme;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UIView *viewForBill;
- (IBAction)confirmBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnFeedBack;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lblLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;

@end
