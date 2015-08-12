//
//  TermsVC.m
//  SG Taxi
//
//  Created by My Mac on 12/5/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "TermsVC.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface TermsVC ()

@end

@implementation TermsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"PLEASE_WAIT", nil)];
    [super setBackBarItem];
    
    NSURL *websiteUrl = [NSURL URLWithString:PRIVACY_URL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [self.webViewTerms loadRequest:urlRequest];
    
    // Do any additional setup after loading the view.
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [APPDELEGATE hideLoadingView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
