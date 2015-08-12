//
//  ShareVC.h
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"

@interface ContactUsVC : BaseVC
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic,strong) NSMutableArray *arrInformation;
@property (nonatomic,strong) NSDictionary *dictContent;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigation;

@end
