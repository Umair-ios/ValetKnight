//
//  HomeVC.h
//  Wag
//
//  Created by Elluminati - macbook on 20/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import <CoreLocation/CoreLocation.h>

@interface HomeVC : BaseVC <CLLocationManagerDelegate>
{
    
}
@property(nonatomic,weak)IBOutlet UILabel *lblName;

-(IBAction)onClickSignIn:(id)sender;
-(IBAction)onClickRegister:(id)sender;

@end
