//
//  TermsVC.h
//  SG Taxi
//
//  Created by My Mac on 12/5/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"

@interface TermsVC : BaseVC <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webViewTerms;
- (IBAction)backBtnPressed:(id)sender;

@end
