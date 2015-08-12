//
//  OptionsVC.h
//  TaxiNow
//
//  Created by Dev on 27/03/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsVC : UIViewController <UITextViewDelegate>
{
    UILabel *headerLbl;
}

@property (strong, nonatomic) IBOutlet UITextField *sourceLocationTxt;
@property (nonatomic,strong) NSString *strForSourceAdd; //strForSourceLat
@property (nonatomic,strong) NSString *strForDestAdd; //strForDestLat
@property (nonatomic,strong) NSString *strForCarType;

@end
