//
//  ShareVC.m
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ContactUsVC.h"

@interface ContactUsVC ()
{
    NSString *strForHtml;
}

@end

@implementation ContactUsVC

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
     [super setBackBarItem];
    self.btnNavigation.titleLabel.text=[self.dictContent valueForKey:@"title"];
    self.btnNavigation.titleLabel.font=[UberStyleGuide fontRegular];
   
    
    [self.webView setDelegate:self];
    
    NSString *urlAddress =[self.dictContent valueForKey:@"content"];
    [self.webView loadHTMLString:urlAddress baseURL:nil];
  
    
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
