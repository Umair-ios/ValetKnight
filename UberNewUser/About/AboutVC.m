//
//  AboutVC.m
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()
{
    NSString *strForHtml;
}
@end

@implementation AboutVC

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
    
    self.btnNavigation.titleLabel.font=[UberStyleGuide fontRegular];
    //[super setNavBarTitle:TITLE_ABOUT];
    [super setBackBarItem];
    
    for(NSMutableDictionary *dict in self.arrInformation)
    {
        if([[dict valueForKey:@"title"] isEqualToString:@"About Us"])
        {
            strForHtml=[dict valueForKey:@"content"];
        }
    }
    
     [self.webView loadHTMLString:strForHtml baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
